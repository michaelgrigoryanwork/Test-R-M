//
//  RMCharacter.swift
//  Test R&M
//
//  Created by Michael Grigoryan on 23.07.24.
//

import SwiftUI

struct RMCharacterCharactersResponse: Decodable, Equatable {
    let results: [RMCharacter]
}

struct RMCharacter: Identifiable, Decodable, Equatable, Hashable {
    static func == (lhs: RMCharacter, rhs: RMCharacter) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case status
        case imageURL = "image"
        case createdDate = "created"
        
        case gender
        case species
        case type
        case origin
        case episodes = "episode"
    }

    // Common
    let id: Int
    let name: String
    let status: Status
    let imageURL: URL?
    let createdDate: Date?
    
    // Detail
    let gender: Gender
    let species: String?
    let type: String?
    let origin: Origin?
    let episodes: [URL]?
}

extension RMCharacter {
    enum Status: String, Codable, CaseIterable {
        case all
        case alive
        case dead
        case unknown
        
        var title: String {
            switch self {
            case .all:
                return "all".localized()
            case .alive:
                return "alive".localized()
            case .dead:
                return "dead".localized()
            case .unknown:
                return "unknown".localized()
            }
        }
        
        var color: Color {
            switch self {
            case .all:
                return .primary
            case .alive:
                return .green
            case .dead:
                return .red
            case .unknown:
                return .yellow
            }
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = .init(rawValue: rawValue.lowercased()) ?? .unknown
        }
    }
}

extension RMCharacter {
    enum Gender: String, Codable, CaseIterable {
        case male
        case female
        case genderless
        case unknown
        
        var title: String {
            switch self {
            case .male:
                return "male".localized()
            case .female:
                return "female".localized()
            case .genderless:
                return "genderless".localized()
            case .unknown:
                return "unknown".localized()
            }
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = .init(rawValue: rawValue.lowercased()) ?? .unknown
        }
    }
}

extension RMCharacter {
    struct Origin: Codable {
        let name: String
    }
}

extension RMCharacter {
    struct Input {
        let page: Int
        let name: String
        let status: String
        
        var queryItems: [URLQueryItem] {
            var queryItems: [URLQueryItem] = [
                .init(name: "name", value: name),
                .init(name: "page", value: "\(page)")
            ]
            if status != Status.all.rawValue {
                queryItems.append(.init(name: "status", value: status))
            }
            return queryItems
        }
    }
}
