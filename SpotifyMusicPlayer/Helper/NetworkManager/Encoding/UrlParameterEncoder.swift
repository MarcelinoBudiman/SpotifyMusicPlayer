//
//  UrlParameterEncoder.swift
//  SpotifyMusicPlayer
//
//  Created by Marcelino Budiman on 17/05/25.
//

import Foundation

public struct URLParameterEncoder: ParameterEncoder{
    public func encode(urlRequest: inout URLRequest, with paramaters: Parameters) throws {
        guard let url = urlRequest.url else {throw NetworkError.missingURL}

        if var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false), !paramaters.isEmpty{
            urlComponent.queryItems = [URLQueryItem]()

            for (key, value) in paramaters{
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                urlComponent.queryItems?.append(queryItem)
            }

            urlRequest.url = urlComponent.url

        }

        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil{
            urlRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }
    }
}
