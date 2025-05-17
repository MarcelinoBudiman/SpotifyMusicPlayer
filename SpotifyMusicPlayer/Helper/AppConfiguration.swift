//
//  AppConfiguration.swift
//  SpotifyMusicPlayer
//
//  Created by Marcelino Budiman on 17/05/25.
//

import Foundation

struct AppConfiguration {
    
    static let baseURL = URL(string: "https://api.spotify.com")!
    
    static var token: String {
        return "Bearer \(SpotifySessionManager.shared.session?.accessToken ?? "")"
    }
    
}
