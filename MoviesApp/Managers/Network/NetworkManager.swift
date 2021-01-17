//
//  NetworkManager.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 30.09.2020.
//

import Foundation

protocol Network {
    func getData(with endpoint: EndpointProtocol, completion: @escaping ((Result<Data,Error>) -> Void))
}

class NetworkManager {
    //    private let session = URLSession(configuration: .default)
}

extension NetworkManager: Network {
    func getData(with endpoint: EndpointProtocol, completion: @escaping ((Result<Data, Error>) -> Void)) {
        guard let request = performRequest(for: endpoint) else {
            completion(.failure(NetworkManagerError.requestError))
            return
        }
        
        sendRequest(request, completion: completion)
    }
}

private extension NetworkManager {
    func performRequest(for endpoint: EndpointProtocol) -> URLRequest? {
        guard var urlComponents = URLComponents(string: endpoint.fullURL) else {
            return nil
        }
        
        urlComponents.queryItems = endpoint.params.compactMap { param -> URLQueryItem in
            return URLQueryItem(name: param.key, value: param.value)
        }
        
        guard let url = urlComponents.url else { return nil }
        
        let urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData)
        return urlRequest
    }
    
    func sendRequest(_ request: URLRequest, completion: @escaping ((Result<Data, Error>) -> Void)) {
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            
            if let error = error {
                completion(.failure(error))
            }
            
            guard let data = data else { return }
            completion(.success(data))
        }
        
        task.resume()
    }
}

enum NetworkManagerError: LocalizedError {
    case requestError
    
    var errorDescription: String? {
        return "The request URL is wrong"
    }
}
