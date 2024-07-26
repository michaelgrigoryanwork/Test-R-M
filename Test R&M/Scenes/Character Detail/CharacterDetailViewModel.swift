//
//  CharacterDetailViewModel.swift
//  Test R&M
//
//  Created by Michael Grigoryan on 24.07.24.
//

import SwiftUI

final class CharacterDetailViewModel: ObservableObject {
    @Published private(set) var data = [EpisodeData]() {
        didSet {
            print(data.map({$0.characters.map({$0.id})}))
        }
    }
    @Published private(set) var isLoading: Bool = true
        
    var shouldShowNoResults: Bool {
        return !isLoading && data.isEmpty
    }
    
    private var character: RMCharacter?
    
    private let episodesService: EpisodesServiceProtocol
    private let charactersService: CharactersServiceProtocol

    init(episodesService: EpisodesServiceProtocol = EpisodesService(),
         charactersService: CharactersServiceProtocol = CharactersService(),
         character: RMCharacter? = nil) {
        self.episodesService = episodesService
        self.charactersService = charactersService
        self.character = character
    }
    
    func setCharacter(character: RMCharacter) {
        self.character = character
    }
}

extension CharacterDetailViewModel {
    func loadEpisodes() {
        data = []
        loadData()
    }
    
    private func loadData() {
        isLoading = true
        Task {
            do {
                let ids = (character.map({$0.episodes ?? []}) ?? []).map({ $0.lastPathComponent })
                if ids.count == 1 {
                    let onlyEpisode = try await episodesService.getOnlyEpisode(id: ids.first!)
                    await MainActor.run {
                        self.data = [.init(episode: onlyEpisode, characters: [])]
                        self.loadCharacters(episode: onlyEpisode)
                        isLoading = false
                    }
                } else {
                    let episodes = try await episodesService.getEpisodes(ids: ids)
                    await MainActor.run {
                        episodes.forEach { episode in
                            self.data.append(EpisodeData(episode: episode, characters: []))
                            self.loadCharacters(episode: episode)
                        }
                        isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
    
    private func loadCharacters(episode: RMEpisode) {
        let ids = episode.characters?.compactMap({ $0.lastPathComponent }) ?? []
        Task(priority: .low) {
            do {
                let characters = try await charactersService.getCharacters(ids: ids)
                if let element = self.data.first(where: { $0.episode.id == episode.id }) {
                    element.updateCharacters(characters: characters)
                    await MainActor.run {
                        self.data = data
                    }
                }
            } catch {
                print(error)
            }
        }
    }
}

extension CharacterDetailViewModel {
    final class EpisodeData {
        private(set) var episode: RMEpisode
        private(set) var characters: [RMCharacter]
        
        init(episode: RMEpisode, characters: [RMCharacter]) {
            self.episode = episode
            self.characters = characters
        }
        
        func updateCharacters(characters: [RMCharacter]) {
            self.characters = characters
        }
    }
}
