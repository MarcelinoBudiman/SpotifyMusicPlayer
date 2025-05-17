//
//  SpotifySessionData.swift
//  SpotifyMusicPlayer
//
//  Created by Marcelino Budiman on 17/05/25.
//

import Foundation

struct SpotifySessionData: Codable {
    let accessToken: String
    let refreshToken: String?
    let expirationDate: Date
}
