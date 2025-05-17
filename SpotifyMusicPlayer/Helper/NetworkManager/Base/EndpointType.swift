//
//  EndpointType.swift
//  SpotifyMusicPlayer
//
//  Created by Marcelino Budiman on 17/05/25.
//

import Foundation

protocol EndpointType{
    var baseUrl: URL {get}
    var path: String {get}
    var httpMethod: HTTPMethod {get}
    var task: HTTPTask {get}
    var headers: HTTPHeaders? {get}
}

enum HTTPMethod: String{
    case get = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
}

public typealias HTTPHeaders = [String:String]

public enum HTTPTask{
    case request
    case requestParameters(bodyParameters: Parameters?, bodyEncoding: ParameterEncoding, urlParameters: Parameters?)
    case requestParametersAndHeaders(bodyParamaters: Parameters?, bodyEncoding: ParameterEncoding, urlParameters: Parameters?, addtionHeaders: HTTPHeaders?)
}
