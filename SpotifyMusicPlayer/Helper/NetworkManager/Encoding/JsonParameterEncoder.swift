//
//  JsonParameterEncoder.swift
//  SpotifyMusicPlayer
//
//  Created by Marcelino Budiman on 17/05/25.
//

import Foundation

public struct JSONParameterEncoder: ParameterEncoder{
    public func encode(urlRequest: inout URLRequest, with paramaters: Parameters) throws {
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: paramaters, options: .prettyPrinted)
            urlRequest.httpBody = jsonData
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }catch{
            throw NetworkError.encodingFailed
        }
    }
}
