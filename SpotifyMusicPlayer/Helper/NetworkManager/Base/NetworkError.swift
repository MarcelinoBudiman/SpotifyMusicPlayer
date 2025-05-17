//
//  NetworkError.swift
//  SpotifyMusicPlayer
//
//  Created by Marcelino Budiman on 17/05/25.
//

import Foundation

public enum NetworkError: String, Error{
    case authenticationError
    case badRequest
    case outdated
    case failed
    case noData
    case generic
    case forbidden
    case notFound
    case badGateway
    case serviceUnavailable
    case noInternet = "No Internet"
    case unableToDecode = "The server returned data in an unexpected format. Try updating the app."
    case invalidResponse = "Invalid response"
    case parametersNil = "Parameters were nil"
    case encodingFailed = "Parameters Encoding failed"
    case missingURL = "URL is nil"
}
