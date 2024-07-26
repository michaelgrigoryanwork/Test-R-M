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
        let urlString = Config.episodeURL + ids.joined(separator: ",")
        let models: [RMEpisode] = try await apiManager.fetch(urlString: urlString)
        return models
    }
    
    func getOnlyEpisode(id: String) async throws -> RMEpisode {
        let model: RMEpisode = try await apiManager.fetch(urlString: Config.episodeURL + id)
        return model
    }
}

private extension EpisodesService {
    struct Config {
        static let episodeURL = "https://rickandmortyapi.com/api/episode/"
    }
}
