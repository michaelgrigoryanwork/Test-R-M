//
//  EpisodesService.swift
//  Test R&M
//
//  Created by Michael Grigoryan on 24.07.24.
//

import Foundation

protocol EpisodesServiceProtocol: AnyObject {
    func getEpisodes(ids: [String]) async throws -> [RMEpisode]
    func getOnlyEpisode(id: String) async throws -> RMEpisode
}

final class EpisodesService {
    private let apiManager: APIManagerProtocol
    
    init(apiManager: APIManagerProtocol = APIManager()) {
        self.apiManager = apiManager
    }
}

extension EpisodesService: EpisodesServiceProtocol {
    func getEpisodes(ids: [String]) async throws -> [RMEpisode] {
        guard !ids.isEmpty else {
            throw EpisodesServiceError.emptyIDList
        }
        let encodedIDs = ids.joined(separator: ",")
        guard let url = URL(string: Config.episodeURL + encodedIDs) else {
            throw EpisodesServiceError.invalidURL
        }
        let models: [RMEpisode] = try await apiManager.fetch(urlString: url.absoluteString)
        return models
    }
    
    func getOnlyEpisode(id: String) async throws -> RMEpisode {
        guard !id.isEmpty else {
            throw EpisodesServiceError.invalidID
        }
        let urlString = Config.episodeURL + id
        guard let url = URL(string: urlString) else {
            throw EpisodesServiceError.invalidURL
        }
        let model: RMEpisode = try await apiManager.fetch(urlString: url.absoluteString)
        return model
    }
}

private extension EpisodesService {
    struct Config {
        static let episodeURL = "https://rickandmortyapi.com/api/episode/"
    }
    
    enum EpisodesServiceError: Error {
        case emptyIDList
        case invalidID
        case invalidURL
    }
}
