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
        let urlString = Config.characterURL + ids.joined(separator: ",")
        let models: [RMCharacter] = try await apiManager.fetch(urlString: urlString)
        return models
    }
}

private extension CharactersService {
    struct Config {
        static let characterURL = "https://rickandmortyapi.com/api/character/"
    }
}
