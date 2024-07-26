//
//  CharactersView.swift
//  Test R&M
//
//  Created by Michael Grigoryan on 23.07.24.
//

import SwiftUI

struct CharactersView: View {
    @StateObject var viewModel = CharactersViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                if viewModel.isLoading {
                    LoadingTextView(title: "loading_data".localized())
                        .listRowSeparator(.hidden)
                }
                
                if viewModel.shouldShowNoResults {
                    LoadingTextView(title: "no_results".localized())
                        .listRowSeparator(.hidden)
                }
                
                ForEach(viewModel.characters) { character in
                    NavigationLink(value: character) {
                        CharacterItemView(character: character)
                            .onAppear {
                                if viewModel.shouldPaginate(character: character) {
                                    viewModel.loadMoreCharacters()
                                }
                            }
                    }
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .refreshable {
                viewModel.loadCharacters()
            }
            .navigationTitle("characters")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText)
            .onChange(of: viewModel.searchText, { oldValue, newValue in
                viewModel.scheduleLoadCharacters()
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    CharacterStatusFilterToolbarView(status: $viewModel.status)
                }
            }
            .navigationDestination(for: RMCharacter.self) { character in
                CharacterDetailView(character: character)
            }
        }
        .tint(.primary)
        .onAppear {
            viewModel.loadCharacters()
        }
    }
}

#Preview {
    CharactersView()
}

struct CharacterItemView: View {
    private let character: RMCharacter
    
    init(character: RMCharacter) {
        self.character = character
    }
    
    var body: some View {
        HStack(spacing: 16) {
            CharacterImageView(url: character.imageURL, size: 96)
            
            VStack(alignment: .leading) {
                Text(character.name)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.1)
                
                Text(character.status.title)
                    .foregroundStyle(character.status.color)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 8)
                
                if let dateString = character.createdDate?.toString(dateFormat: .created) {
                    Text(String(format: "%@: %@", "created".localized(), dateString))
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                }
            }
        }
    }
}

fileprivate extension CharactersView {
    struct CharacterStatusFilterToolbarView: View {
        @Binding var status: RMCharacter.Status
        
        var body: some View {
            Menu {
                ForEach(RMCharacter.Status.allCases, id: \.self) { status in
                    Button( action: {
                        self.status = status
                    }) {
                        if self.status == status {
                            Text("📌 \(status.title)")
                        } else {
                            Text(status.title)
                        }
                    }
                }
            } label: {
                Image(systemName: "line.horizontal.3.decrease.circle")
            }
        }
    }
}
