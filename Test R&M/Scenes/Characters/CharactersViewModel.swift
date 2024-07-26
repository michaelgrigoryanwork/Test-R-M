//
//  CharactersViewModel.swift
//  Test R&M
//
//  Created by Michael Grigoryan on 23.07.24.
//

import SwiftUI

final class CharactersViewModel: ObservableObject {
    @Published var searchText = ""
    
    @Published private(set) var characters = [RMCharacter]()
    @Published private(set) var isLoading: Bool = true
    
    @Published var status: RMCharacter.Status = .all {
        didSet {
            loadCharacters()
        }
    }
    
    var shouldShowNoResults: Bool {
        return !isLoading && !searchText.isEmpty && characters.isEmpty
    }
    
    private var debounceTimer: Timer?
    private let debounceInterval = 0.5
        
    private let charactersService: CharactersServiceProtocol
    
    private(set) var currentPage: Int = 1
    
    init(charactersService: CharactersServiceProtocol = CharactersService()) {
        self.charactersService = charactersService
    }
}

extension CharactersViewModel {
    func loadCharacters() {
        characters.removeAll()
        currentPage = 1
        loadData()
    }
    
    func scheduleLoadCharacters() {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: debounceInterval, repeats: false) { [weak self] _ in
            self?.loadCharacters()
        }
    }
    
    func loadMoreCharacters() {
        currentPage += 1
        loadData()
    }
    
    private func loadData() {
        isLoading = true
        Task {
            do {
                let input = RMCharacter.Input.init(page: currentPage,
                                                   name: searchText,
                                                   status: status.rawValue)
                let response = try await charactersService.getCharacters(input: input)
                let characters = response.results
                await MainActor.run {
                    self.characters += characters
                    //                    updateCharacters(characters: characters)
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}

extension CharactersViewModel {
    func setStatus(status: RMCharacter.Status) {
        self.status = status
    }
}

extension CharactersViewModel {
    func shouldPaginate(character: RMCharacter) -> Bool {
        guard !characters.isEmpty else {
            return false
        }
        return characters.last?.id == character.id && !isLoading
    }
}
