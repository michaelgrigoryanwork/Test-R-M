//
//  APIManager.swift
//  Test R&M
//
//  Created by Michael Grigoryan on 23.07.24.
//

import Foundation

protocol APIManagerProtocol: AnyObject {
    func fetch<T: Decodable>(urlString: String,
                             queryItems: [URLQueryItem],
                             reloadIgnoringLocalCacheData: Bool) async throws -> T
}

extension APIManagerProtocol {
    func fetch<T: Decodable>(urlString: String,
                             queryItems: [URLQueryItem] = [],
                             reloadIgnoringLocalCacheData: Bool = true) async throws -> T {
        try await fetch(urlString: urlString,
                        queryItems: queryItems,
                        reloadIgnoringLocalCacheData: reloadIgnoringLocalCacheData)
    }
}

final class APIManager: APIManagerProtocol {
    func fetch<T: Decodable>(urlString: String,
                             queryItems: [URLQueryItem],
                             reloadIgnoringLocalCacheData: Bool) async throws -> T {
        let components = getURLComponents(urlString: urlString,
                                          queryItems: queryItems)
        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        let urlRequest = getURLRequest(url: url)
        let (data, response) = try await getSession(reloadIgnoringLocalCacheData: reloadIgnoringLocalCacheData)
            .data(for: urlRequest)
        print(response)
        do {
            let decodedData = try getJSONDecoder().decode(T.self, from: data)
            print(decodedData)
            return decodedData
        } catch {
            print(error)
            throw error
        }
    }
}

private extension APIManager {
    func getSession(reloadIgnoringLocalCacheData: Bool) -> URLSession {
        let config = URLSessionConfiguration.default
        if reloadIgnoringLocalCacheData {
            config.requestCachePolicy = .reloadIgnoringLocalCacheData
            config.urlCache = nil
        }
        let session = URLSession(configuration: config)
        return session
    }
    
    func getURLComponents(urlString: String, queryItems: [URLQueryItem]) -> URLComponents? {
        var components = URLComponents(string: urlString)
        components?.queryItems = queryItems
        return components
    }
    
    func getURLRequest(url: URL, method: HTTPMethod = .get) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        return urlRequest
    }
    
    func getJSONDecoder() -> JSONDecoder {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601withOptionalFractionalSeconds
        return jsonDecoder
    }
}

private extension APIManager {
    enum HTTPMethod: String {
        case get = "GET"
    }
}
