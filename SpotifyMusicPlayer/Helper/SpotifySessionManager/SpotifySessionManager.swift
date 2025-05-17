//
//  SpotifySessionManager.swift
//  SpotifyMusicPlayer
//
//  Created by Marcelino Budiman on 17/05/25.
//

import Foundation
import SpotifyiOS


protocol SpotifyPlayerDelegate: AnyObject {
    func didChangePlayerState(_ state: SPTAppRemotePlayerState)
}

class SpotifySessionManager: NSObject {
    
    static let shared = SpotifySessionManager()
    
    private let clientID = "938424997fbb41e095914f59d0038930"
    private let redirectURI = URL(string: "spotify-music-player://spotify-login-callback")!
    
    weak var delegate: SpotifyPlayerDelegate?
    
    private var pendingTrackURI: String?
    
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
        else { return }
        
        self.session = decoded
        
        if decoded.expirationDate > Date() {
            appRemote.connectionParameters.accessToken = session?.accessToken
        } else {
            session = nil
        }
    }
    
    func login(from viewController: UIViewController) {
        let scopes: SPTScope = [.appRemoteControl,
                                .userReadEmail,
                                .userModifyPlaybackState,
                                .userReadPlaybackState,
                                .userReadCurrentlyPlaying]
        
        if sessionManager.isSpotifyAppInstalled {
            sessionManager.initiateSession(with: scopes, options: .default, campaign: nil)
        } else {
            sessionManager.initiateSession(with: scopes, options: .clientOnly, campaign: nil)
        }
    }
    
    func handleURL(_ url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) {
        _ = sessionManager.application(UIApplication.shared, open: url, options: options)
    }
    
    func connectAppRemote() {
        guard let token = session?.accessToken else {
            print("No access token to connect AppRemote")
            return
        }
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
    
    func play(uri: String) {
        if appRemote.isConnected {
            appRemote.playerAPI?.play(uri, callback: { result, error in
                if let error = error {
                    print("Play failed: \(error.localizedDescription)")
                } else {
                    print("Playing \(uri)")
                }
            })
        } else {
            pendingTrackURI = uri
            connectAppRemote()
        }
    }
}

// MARK: - SPTSessionManagerDelegate
extension SpotifySessionManager: SPTSessionManagerDelegate {
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("Spotify session initiated!")
        self.session = SpotifySessionData(accessToken: session.accessToken,
                                          refreshToken: session.refreshToken,
                                          expirationDate: session.expirationDate)
        connectAppRemote()
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("Spotify session failed: \(error.localizedDescription)")
    }
    
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        print("Spotify session renewed!")
        self.session = SpotifySessionData(accessToken: session.accessToken,
                                          refreshToken: session.refreshToken,
                                          expirationDate: session.expirationDate)
        connectAppRemote()
    }
}

// MARK: - SPTAppRemoteDelegate
extension SpotifySessionManager: SPTAppRemoteDelegate {
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("AppRemote failed connection attempt: \(error?.localizedDescription ?? "unknown")")
        // Retry connecting after delay if needed
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if !self.appRemote.isConnected {
                self.appRemote.connect()
            }
        }
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("AppRemote disconnected: \(error?.localizedDescription ?? "unknown")")
        // Retry connecting after delay if needed
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if !self.appRemote.isConnected {
                self.appRemote.connect()
            }
        }
    }
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("AppRemote connected to Spotify")
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
                print("Failed to subscribe to player state: \(error.localizedDescription)")
            }
        })
        if let uri = pendingTrackURI {
            appRemote.playerAPI?.play(uri, callback: nil)
            pendingTrackURI = nil
        }
    }
}

// MARK: - SPTAppRemotePlayerStateDelegate
extension SpotifySessionManager: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        print("Spotify Track: \(playerState.track.name)")
        delegate?.didChangePlayerState(playerState)
    }
}
