//
//  AppDelegate.swift
//  SpotifyMusicPlayer
//
//  Created by Marcelino Budiman on 17/05/25.
//

import UIKit
import SpotifyiOS

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    // MARK: Initializze Spotify Client SDK
    let SpotifyClientID = "938424997fbb41e095914f59d0038930"
    let SpotifyRedirectURL = URL(string: "spotify-music-player://spotify-login-callback")!

    lazy var configuration: SPTConfiguration = {
        let config = SPTConfiguration(clientID: SpotifyClientID, redirectURL: SpotifyRedirectURL)
        
        config.tokenSwapURL = nil
        config.tokenRefreshURL = nil
        config.playURI = ""
        
        return config
    }()
    
    lazy var sessionManager: SPTSessionManager = {
       let manager = SPTSessionManager(configuration: configuration, delegate: self)
       return manager
    }()
    
    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: self.configuration, logLevel: .debug)
        appRemote.delegate = self
      return appRemote
    }()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let rootVC = ViewController()
        
        window?.rootViewController = UINavigationController(rootViewController: rootVC)
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if sessionManager.application(app, open: url, options: options) {
            return true
        }
        
        let parameters = appRemote.authorizationParameters(from: url)

        if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = access_token
            
            UserDefaults.standard.set(access_token, forKey: "accessToken")
            
            } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
                // Show the error
                print("Spotify Auth Error: \(error_description)")
            }
        
        return false
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        if self.appRemote.isConnected {
            self.appRemote.disconnect()
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if let token = self.appRemote.connectionParameters.accessToken {
            appRemote.connectionParameters.accessToken = token
            self.appRemote.connect()
        }
    }

    // MARK: UISceneSession Lifecycle

//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }


}

extension AppDelegate: SPTSessionManagerDelegate {
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("Spotify session initiated!")
        
        UserDefaults.standard.set(session.accessToken, forKey: "accessToken")
        appRemote.connectionParameters.accessToken = session.accessToken
        appRemote.connect()
        
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: any Error) {
        print("Spotify login failed: \(error)")
    }
    
}

extension AppDelegate: SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: (any Error)?) {
        print("Failed to connect to spotify!")
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: (any Error)?) {
        print("Disconnected from spotify!")
    }
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("Connected to spotify!")
        
        self.appRemote.playerAPI?.delegate = self
        
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
                debugPrint("Error subscribing to player state = " + error.localizedDescription)
            }
      })
        
    }
    
    func playerStateDidChange(_ playerState: any SPTAppRemotePlayerState) {
        print("player state changed")
        
        debugPrint("Track name: \(playerState.track.name)")
    }
    
}

