//
//  Enums.swift
//  SpotifyMusicPlayer
//
//  Created by Marcelino Budiman on 17/05/25.
//

import Foundation

enum ObservableEventEnum<T> {
    case next(T)
    case error(NetworkError)
    case completed(T)
}
