//
//  SpotifySessionManager.swift
//  SpotifyMusicPlayer
//
//  Created by Marcelino Budiman on 17/05/25.
//

import Foundation
import SpotifyiOS

class SpotifySessionManager: NSObject {
    
    static let shared = SpotifySessionManager()
    
    private let clientID = "938424997fbb41e095914f59d0038930"
    private let redirectURI = URL(string: "spotify-music-player://spotify-login-callback")!
    
    private lazy var configuration: SPTConfiguration = {
        let config = SPTConfiguration(clientID: clientID, redirectURL: redirectURI)
        
        config.tokenSwapURL = nil
        config.tokenRefreshURL = nil
        
        return config
    }()

    lazy var sessionManager: SPTSessionManager = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self)
        return manager
    }()

    lazy var appRemote: SPTAppRemote = {
        let remote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        remote.delegate = self
        
        return remote
    }()
    
    private let sessionKey = "spotifySession"
    
    var session: SpotifySessionData? {
        didSet {
            guard let session = session else { return }
            if let encoded = try? JSONEncoder().encode(session) {
                UserDefaults.standard.set(encoded, forKey: sessionKey)
            }
        }
    }

    override init() {
        
        super.init()

        loadSession()
    }
    
    func loadSession() {
        guard let data = UserDefaults.standard.data(forKey: sessionKey),
              let decoded = try? JSONDecoder().decode(SpotifySessionData.self, from: data)
        else {
            return
        }

        self.session = decoded
        
        if decoded.expirationDate > Date() {
            appRemote.connectionParameters.accessToken = session?.accessToken
        } else {
            renew()
        }
    }
    
    func login(from viewController: UIViewController) {
        let scopes: SPTScope = [.appRemoteControl, .userReadEmail, .userModifyPlaybackState, .userReadPlaybackState]
        
        if sessionManager.isSpotifyAppInstalled {
            sessionManager.initiateSession(with: scopes, options: .default, campaign: nil)
        } else {
            sessionManager.initiateSession(with: scopes, options: .clientOnly, campaign: nil)
        }
    }
    
    func handleURL(_ url: URL) {
        sessionManager.application(UIApplication.shared, open: url, options: [:])
    }
    
    func connectAppRemote() {
        guard let token = session?.accessToken else { return }
        appRemote.connectionParameters.accessToken = token
        appRemote.connect()
    }

    func disconnectAppRemote() {
        if appRemote.isConnected {
            appRemote.disconnect()
        }
    }
    
    func renew() {
        sessionManager.renewSession()
    }
    
    func isLoggedIn() -> Bool {
        return session?.expirationDate ?? Date.distantPast > Date()
    }
    
}

// MARK: - Implement Spotify SDK Delegate
extension SpotifySessionManager: SPTSessionManagerDelegate {
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("Spotify session initiated!")
        self.session = SpotifySessionData(accessToken: session.accessToken, refreshToken: session.refreshToken, expirationDate: session.expirationDate)
        connectAppRemote()
    }

    func sessionManager(manager: SPTSessionManager, didFailWith error: any Error) {
        print("Spotify session failed: \(error.localizedDescription)")
    }
    
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        self.session = SpotifySessionData(accessToken: session.accessToken, refreshToken: session.refreshToken, expirationDate: session.expirationDate)
        connectAppRemote()
    }
    
}

extension SpotifySessionManager: SPTAppRemoteDelegate {
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: (any Error)?) {
        print("AppRemote failed: \(error?.localizedDescription ?? "unknown")")
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: (any Error)?) {
        print("AppRemote disconnected: \(error?.localizedDescription ?? "unknown")")
    }

    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("AppRemote connected to Spotify")
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { _, error in
            if let error = error {
                print("Failed to subscribe to player state: \(error.localizedDescription)")
            }
        })
    }
}

extension SpotifySessionManager: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: any SPTAppRemotePlayerState) {
        print("Spotify Track: \(playerState.track.name)")
    }
}
