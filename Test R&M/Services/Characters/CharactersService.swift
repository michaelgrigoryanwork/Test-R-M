//
//  CharactersService.swift
//  Test R&M
//
//  Created by Michael Grigoryan on 23.07.24.
//

import Foundation

protocol CharactersServiceProtocol: AnyObject {
    func getCharacters(input: RMCharacter.Input) async throws -> RMCharacterCharactersResponse
    func getCharacters(ids: [String]) async throws -> [RMCharacter]
}

final class CharactersService {
    private let apiManager: APIManagerProtocol
    
    init(apiManager: APIManagerProtocol = APIManager()) {
        self.apiManager = apiManager
    }
}

extension CharactersService: CharactersServiceProtocol {
    func getCharacters(input: RMCharacter.Input) async throws -> RMCharacterCharactersResponse {
        let response: RMCharacterCharactersResponse = try await apiManager.fetch(urlString: Config.characterURL,
                                                                                 queryItems: input.queryItems)
        return response
    }
    
    func getCharacters(ids: [String]) async throws -> [RMCharacter] {
        guard !ids.isEmpty else {
            throw CharactersServiceError.emptyIDList
        }
        let encodedIDs = ids.joined(separator: ",")
        guard let url = URL(string: Config.characterURL + encodedIDs) else {
            throw CharactersServiceError.invalidURL
        }
        let models: [RMCharacter] = try await apiManager.fetch(urlString: url.absoluteString)
        return models
    }
}

private extension CharactersService {
    struct Config {
        static let characterURL = "https://rickandmortyapi.com/api/character/"
    }
    
    enum CharactersServiceError: Error {
        case emptyIDList
        case invalidURL
    }
}
