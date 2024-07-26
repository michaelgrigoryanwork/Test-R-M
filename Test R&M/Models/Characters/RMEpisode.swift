//
//  RMEpisode.swift
//  Test R&M
//
//  Created by Michael Grigoryan on 24.07.24.
//

import SwiftUI

struct RMEpisode: Identifiable, Codable, Equatable, Hashable {
    static func == (lhs: RMEpisode, rhs: RMEpisode) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case characters
    }

    let id: Int
    let name: String
    let characters: [URL]?

    init(id: Int, name: String, characters: [URL]?) {
        self.id = id
        self.name = name
        self.characters = characters
    }
}
