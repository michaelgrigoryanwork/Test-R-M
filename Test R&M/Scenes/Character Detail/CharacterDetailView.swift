//
//  CharacterDetailView.swift
//  Test R&M
//
//  Created by Michael Grigoryan on 24.07.24.
//

import SwiftUI

struct CharacterDetailView: View {
    @StateObject var viewModel = CharacterDetailViewModel()
    
    private let character: RMCharacter
    
    init(character: RMCharacter) {
        self.character = character
    }
    
    var body: some View {
        List {
            Text(character.name)
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
                .lineLimit(0)
                .listRowSeparator(.hidden)
            
            CharacterImageView(url: character.imageURL, size: 192, cornerRadius: 32)
                .listRowSeparator(.hidden)
            
            Text(character.status.title)
                .foregroundStyle(character.status.color)
                .font(.title)
                .multilineTextAlignment(.leading)
                .padding(.bottom, 8)
            
            DetailItemView(iconName: "brain.head.profile",
                           title: "gender".localized() + ":",
                           value: character.gender.title)
            
            if let dateString = character.createdDate?.toString(dateFormat: .created) {
                DetailItemView(iconName: "calendar",
                               title: "creation_date".localized() + ":",
                               value: dateString)
            }
            
            if let species = character.species {
                DetailItemView(iconName: "person",
                               title: "species".localized() + ":",
                               value: species.capitalized)
            }
            
            if let type = character.type {
                DetailItemView(iconName: "chart.bar",
                               title: "type".localized() + ":",
                               value: type.isEmpty ? "-" : type.capitalized)
            }
            
            if let origin = character.origin {
                DetailItemView(iconName: "location",
                               title: "origin".localized() + ":",
                               value: origin.name.capitalized)
            }
            
            DetailItemView(iconName: "play.laptopcomputer",
                           title: "episodes".localized() + ":")
            
            if viewModel.isLoading {
                LoadingTextView(title: "loading_data".localized())
                    .listRowSeparator(.hidden)
            } else if viewModel.shouldShowNoResults {
                LoadingTextView(title: "no_results".localized())
                    .listRowSeparator(.hidden)
            } else {
                ForEach(viewModel.data, id: \.episode.id) { element in
                    DisclosureGroup(element.episode.name, content: {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack {
                                ForEach(element.characters, id: \.id) { character in
                                    VStack {
                                        CharacterImageView(url: character.imageURL, size: 96, cornerRadius: 16)
                                        Text(character.name)
                                            .font(.subheadline)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(0)
                                            .frame(width: 96)
                                    }
                                }
                            }
                            .padding(.zero)
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: .zero, leading: .zero, bottom: .zero, trailing: 16))
                    })
                    .listRowBackground(Color.clear)
                    .tint(.primary)
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            viewModel.loadEpisodes()
        }
        .onAppear {
            viewModel.setCharacter(character: character)
            viewModel.loadEpisodes()
        }
    }
}

#Preview {
    CharacterDetailView(character: (.init(id: 0,
                                          name: "Angry Rick",
                                          status: .alive,
                                          imageURL: .init(string: "https://m.media-amazon.com/images/M/MV5BZjRjOTFkOTktZWUzMi00YzMyLThkMmYtMjEwNmQyNzliYTNmXkEyXkFqcGdeQXVyNzQ1ODk3MTQ@._V1_FMjpg_UX1000_.jpg"),
                                          createdDate: Date(),
                                          gender: .female,
                                          species: "Humanoid",
                                          type: "Rick's Toxic Side",
                                          origin: .init(name: "Earth (C-137)"),
                                          episodes: [.init(string: "https://rickandmortyapi.com/api/episode/11")!])))
}

fileprivate extension CharacterDetailView {
    struct DetailItemView: View {
        private let iconName: String
        private let title: String
        private let value: String?
        
        init(iconName: String, title: String, value: String? = nil) {
            self.iconName = iconName
            self.title = title
            self.value = value
        }
        
        var body: some View {
            HStack(alignment: .top) {
                Image(systemName: iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .font(.title3)
                    .foregroundStyle(.primary)
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.title3)
                    .bold()
                    .multilineTextAlignment(.leading)
                
                if let value {
                    Text(value)
                        .font(.title3)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            .listRowSeparator(.hidden)
        }
    }
}

struct Bookmark: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    var items: [Bookmark]?

    // some example websites
    static let apple = Bookmark(name: "Apple", icon: "1.circle")
    static let bbc = Bookmark(name: "BBC", icon: "square.and.pencil")
    static let swift = Bookmark(name: "Swift", icon: "bolt.fill")
    static let twitter = Bookmark(name: "Twitter", icon: "mic")

    // some example groups
    static let example1 = Bookmark(name: "Favorites", icon: "star", items: [Bookmark.apple, Bookmark.bbc, Bookmark.swift, Bookmark.twitter])
    static let example2 = Bookmark(name: "Recent", icon: "timer", items: [Bookmark.apple, Bookmark.bbc, Bookmark.swift, Bookmark.twitter])
    static let example3 = Bookmark(name: "Recommended", icon: "hand.thumbsup", items: [Bookmark.apple, Bookmark.bbc, Bookmark.swift, Bookmark.twitter])
}
