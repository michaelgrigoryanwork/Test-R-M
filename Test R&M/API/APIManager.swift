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
        guard let url = getURLComponents(urlString: urlString, queryItems: queryItems)?.url else {
            throw APIError.invalidURL
        }
        
        let urlRequest = getURLRequest(url: url)
        let (data, response) = try await getSession(reloadIgnoringLocalCacheData: reloadIgnoringLocalCacheData)
            .data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        do {
            let decodedData = try getJSONDecoder().decode(T.self, from: data)
            return decodedData
        } catch {
            throw APIError.decodingError(error)
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
        return URLSession(configuration: config)
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
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    enum APIError: Error {
        case invalidURL
        case invalidResponse
        case decodingError(Error)
    }
}
