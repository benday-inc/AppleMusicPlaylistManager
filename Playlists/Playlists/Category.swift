//
//  Category.swift
//  Playlists
//
//  Created by Benjamin Day on 6/19/25.
//


import Foundation
import Combine

public struct Category: Codable, Identifiable, Equatable, Sendable {
    public var id: UUID = UUID()
    var name: String
    var genres: [String]
    var artists: [String]
    var composers: [String]

    init() {
        name = ""
        genres = []
        artists = []
        composers = []
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""

        genres = try container.decodeIfPresent([String].self, forKey: .genres) ?? []
        artists = try container.decodeIfPresent([String].self, forKey: .artists) ?? []
        composers = try container.decodeIfPresent([String].self, forKey: .composers) ?? []
    }
}
