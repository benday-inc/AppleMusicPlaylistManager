//
//  MusicCategory.swift
//  Playlists
//
//  Created by Benjamin Day on 6/16/25.
//

import Foundation

/// Represents a custom category of music that can be used to generate playlists
/// A category contains a collection of artists and/or genres to pull from
struct MusicCategory: Identifiable, Hashable, Codable {
    var id = UUID()
    var name: String
    var artists: [IdentifiableString]
    var genres: [IdentifiableString]
    var createdDate: Date
    var lastModifiedDate: Date
    
    init(name: String, artists: [IdentifiableString] = [], genres: [IdentifiableString] = []) {
        self.name = name
        self.artists = artists
        self.genres = genres
        self.createdDate = Date()
        self.lastModifiedDate = Date()
    }
    
    /// Returns true if the category contains the specified artist
    func containsArtist(_ artistName: String) -> Bool {
        return artists.contains { $0.value.lowercased() == artistName.lowercased() }
    }
    
    /// Returns true if the category contains the specified genre
    func containsGenre(_ genreName: String) -> Bool {
        return genres.contains { $0.value.lowercased() == genreName.lowercased() }
    }
    
    /// Returns true if the category contains either the artist or genre
    func containsArtistOrGenre(artistName: String, genreName: String) -> Bool {
        return containsArtist(artistName) || containsGenre(genreName)
    }
    
    /// Adds an artist to the category if not already present
    mutating func addArtist(_ artistName: String) {
        if !containsArtist(artistName) {
            artists.append(IdentifiableString(value: artistName))
            lastModifiedDate = Date()
        }
    }
    
    /// Adds a genre to the category if not already present
    mutating func addGenre(_ genreName: String) {
        if !containsGenre(genreName) {
            genres.append(IdentifiableString(value: genreName))
            lastModifiedDate = Date()
        }
    }
    
    /// Removes an artist from the category
    mutating func removeArtist(_ artistName: String) {
        artists.removeAll { $0.value.lowercased() == artistName.lowercased() }
        lastModifiedDate = Date()
    }
    
    /// Removes a genre from the category
    mutating func removeGenre(_ genreName: String) {
        genres.removeAll { $0.value.lowercased() == genreName.lowercased() }
        lastModifiedDate = Date()
    }
    
    /// Returns the total number of artists and genres in the category
    var totalItems: Int {
        return artists.count + genres.count
    }
    
    /// Returns true if the category is empty (no artists or genres)
    var isEmpty: Bool {
        return artists.isEmpty && genres.isEmpty
    }
    
    /// Updates the name of the category
    mutating func updateName(_ newName: String) {
        self.name = newName
        self.lastModifiedDate = Date()
    }
}

// MARK: - Convenience Extensions

extension MusicCategory {
    /// Creates a category with artists from string array
    static func withArtists(name: String, artistNames: [String]) -> MusicCategory {
        let artists = artistNames.map { IdentifiableString(value: $0) }
        return MusicCategory(name: name, artists: artists)
    }
    
    /// Creates a category with genres from string array
    static func withGenres(name: String, genreNames: [String]) -> MusicCategory {
        let genres = genreNames.map { IdentifiableString(value: $0) }
        return MusicCategory(name: name, genres: genres)
    }
    
    /// Creates a category with both artists and genres from string arrays
    static func withArtistsAndGenres(name: String, artistNames: [String], genreNames: [String]) -> MusicCategory {
        let artists = artistNames.map { IdentifiableString(value: $0) }
        let genres = genreNames.map { IdentifiableString(value: $0) }
        return MusicCategory(name: name, artists: artists, genres: genres)
    }
}
