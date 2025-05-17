//
//  NetworkClient.swift
//  SpotifyMusicPlayer
//
//  Created by Marcelino Budiman on 17/05/25.
//


import Foundation

enum ResultResponse<String>{
    case success
    case failure(String)
}
protocol NetworkClient{
    associatedtype EndPoint: EndpointType
    func sendRequest<T:Decodable>(endpoint: EndPoint, responseModel: T.Type)async -> Result<T, NetworkError>
}

class NetworkSessionClient<Endpoint: EndpointType>: NetworkClient{

    func sendRequest<T:Decodable>(endpoint: Endpoint, responseModel: T.Type)async -> Result<T, NetworkError>{
        let session = URLSession.shared
        do{
            let request = try self.buildRequest(from: endpoint)
            let (data, response) = try await session.data(for: request, delegate: nil)
            guard let response = response as? HTTPURLResponse else{
                return .failure(.invalidResponse)
            }
            let result = self.handleNetworkResponse(response)
            switch result{
            case .success:
                guard let jsonData = try? JSONDecoder().decode(responseModel.self, from: data) else {
                    return .failure(.unableToDecode)
                }
                return .success(jsonData)
            case .failure(let failure):
                return .failure(failure)
            }
        }catch{
            return .failure(.failed)
        }
    }


    fileprivate func buildRequest(from route:  EndPoint) throws -> URLRequest{
        var request = URLRequest(url: route.baseUrl.appendingPathComponent(route.path),
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 10.0)
        request.httpMethod = route.httpMethod.rawValue
        do{
            switch route.task {
            case .request:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            case .requestParameters(let bodyParameters, let bodyEncoding, let urlParameters):
                try self.configureParameters(bodyParameters: bodyParameters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request)

            case .requestParametersAndHeaders(let bodyParamaters, let bodyEncoding, let urlParameters, let headers):
                self.addAdditionalHeaders(headers, request: &request)
                try self.configureParameters(bodyParameters: bodyParamaters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request)
            }
            return request
        }catch{
            throw error
        }

    }

    fileprivate func configureParameters(bodyParameters: Parameters?,
                                         bodyEncoding: ParameterEncoding,
                                         urlParameters: Parameters?,
                                         request: inout URLRequest) throws {
        do {
            try bodyEncoding.encode(urlRequest: &request, bodyParameters: bodyParameters, urlParameters: urlParameters)
        }catch{
            throw error
        }
    }

    fileprivate func addAdditionalHeaders(_ addtionalHeaders: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = addtionalHeaders else {return}
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }

    fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> ResultResponse<NetworkError> {
        print("Status Code \(response.statusCode)")
        switch response.statusCode {
        case 200...299 :
            return .success
        case 400 :
            return .failure(NetworkError.badRequest)
        case 401:
            return .failure(NetworkError.authenticationError)
        case 403:
            return .failure(NetworkError.forbidden)
        case 404:
            return .failure(NetworkError.notFound)
        case 500:
            return .failure(NetworkError.failed)
        case 502 :
            return .failure(NetworkError.badGateway)
        case 503:
            return .failure(NetworkError.serviceUnavailable)
        default:
            return .failure(NetworkError.failed)
        }
    }
}
