//
//  MusicPlayerEndpoint.swift
//  SpotifyMusicPlayer
//
//  Created by Marcelino Budiman on 17/05/25.
//


import Foundation

enum MusicPlayerEndPoint{
    case getSongByArtist(urlParameter: Parameters)
}
extension MusicPlayerEndPoint: EndpointType{
    var baseUrl: URL {
        return AppConfiguration.baseURL
    }
    
    var path: String {
        switch self {
        case .getSongByArtist:
            return "v1/search"

        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getSongByArtist:
            return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .getSongByArtist(let urlParameter):
            return .requestParametersAndHeaders(bodyParamaters: nil, bodyEncoding: .urlEncoding, urlParameters: urlParameter, addtionHeaders: headers)

        }
    }
    
    var headers: HTTPHeaders? {
        return ["Authorization": AppConfiguration.token]
    }
}
