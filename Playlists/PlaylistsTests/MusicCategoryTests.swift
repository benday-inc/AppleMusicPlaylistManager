//
//  MusicCategoryTests.swift
//  PlaylistsTests
//
//  Created by Benjamin Day on 6/16/25.
//

import XCTest
@testable import Playlists

final class MusicCategoryTests: XCTestCase {
    
    // MARK: - Test Setup
    
    func testCategoryInitialization() throws {
        let category = MusicCategory(name: "Test Category")
        
        XCTAssertFalse(category.id.uuidString.isEmpty)
        XCTAssertEqual(category.name, "Test Category")
        XCTAssertTrue(category.artists.isEmpty)
        XCTAssertTrue(category.genres.isEmpty)
        XCTAssertTrue(category.isEmpty)
        XCTAssertEqual(category.totalItems, 0)
    }
    
    func testCategoryWithArtists() throws {
        let artists = [IdentifiableString(value: "Artist 1"), IdentifiableString(value: "Artist 2")]
        let category = MusicCategory(name: "Test Category", artists: artists)
        
        XCTAssertEqual(category.artists.count, 2)
        XCTAssertTrue(category.genres.isEmpty)
        XCTAssertFalse(category.isEmpty)
        XCTAssertEqual(category.totalItems, 2)
    }
    
    func testCategoryWithGenres() throws {
        let genres = [IdentifiableString(value: "Jazz"), IdentifiableString(value: "Blues")]
        let category = MusicCategory(name: "Test Category", genres: genres)
        
        XCTAssertTrue(category.artists.isEmpty)
        XCTAssertEqual(category.genres.count, 2)
        XCTAssertFalse(category.isEmpty)
        XCTAssertEqual(category.totalItems, 2)
    }
    
    // MARK: - Test Artist Operations
    
    func testContainsArtist() throws {
        var category = MusicCategory(name: "Test Category")
        category.addArtist("Spyro Gyra")
        category.addArtist("Rippingtons")
        
        XCTAssertTrue(category.containsArtist("Spyro Gyra"))
        XCTAssertTrue(category.containsArtist("SPYRO GYRA")) // Case insensitive
        XCTAssertTrue(category.containsArtist("spyro gyra"))
        XCTAssertFalse(category.containsArtist("David Benoit"))
    }
    
    func testAddArtist() throws {
        var category = MusicCategory(name: "Test Category")
        let initialDate = category.lastModifiedDate
        
        // Sleep briefly to ensure date difference
        Thread.sleep(forTimeInterval: 0.001)
        
        category.addArtist("Everette Harp")
        
        XCTAssertEqual(category.artists.count, 1)
        XCTAssertEqual(category.artists.first?.value, "Everette Harp")
        XCTAssertGreaterThan(category.lastModifiedDate, initialDate)
    }
    
    func testAddDuplicateArtist() throws {
        var category = MusicCategory(name: "Test Category")
        category.addArtist("Spyro Gyra")
        category.addArtist("spyro gyra") // Case different
        
        XCTAssertEqual(category.artists.count, 1) // Should not add duplicate
    }
    
    func testRemoveArtist() throws {
        var category = MusicCategory(name: "Test Category")
        category.addArtist("Spyro Gyra")
        category.addArtist("Rippingtons")
        
        let initialDate = category.lastModifiedDate
        Thread.sleep(forTimeInterval: 0.001)
        
        category.removeArtist("spyro gyra") // Case insensitive removal
        
        XCTAssertEqual(category.artists.count, 1)
        XCTAssertFalse(category.containsArtist("Spyro Gyra"))
        XCTAssertTrue(category.containsArtist("Rippingtons"))
        XCTAssertGreaterThan(category.lastModifiedDate, initialDate)
    }
    
    // MARK: - Test Genre Operations
    
    func testContainsGenre() throws {
        var category = MusicCategory(name: "Test Category")
        category.addGenre("Jazz")
        category.addGenre("Smooth Jazz")
        
        XCTAssertTrue(category.containsGenre("Jazz"))
        XCTAssertTrue(category.containsGenre("JAZZ")) // Case insensitive
        XCTAssertTrue(category.containsGenre("smooth jazz"))
        XCTAssertFalse(category.containsGenre("Classical"))
    }
    
    func testAddGenre() throws {
        var category = MusicCategory(name: "Test Category")
        let initialDate = category.lastModifiedDate
        
        Thread.sleep(forTimeInterval: 0.001)
        
        category.addGenre("Fusion")
        
        XCTAssertEqual(category.genres.count, 1)
        XCTAssertEqual(category.genres.first?.value, "Fusion")
        XCTAssertGreaterThan(category.lastModifiedDate, initialDate)
    }
    
    func testAddDuplicateGenre() throws {
        var category = MusicCategory(name: "Test Category")
        category.addGenre("Jazz")
        category.addGenre("JAZZ") // Case different
        
        XCTAssertEqual(category.genres.count, 1) // Should not add duplicate
    }
    
    func testRemoveGenre() throws {
        var category = MusicCategory(name: "Test Category")
        category.addGenre("Jazz")
        category.addGenre("Blues")
        
        let initialDate = category.lastModifiedDate
        Thread.sleep(forTimeInterval: 0.001)
        
        category.removeGenre("JAZZ") // Case insensitive removal
        
        XCTAssertEqual(category.genres.count, 1)
        XCTAssertFalse(category.containsGenre("Jazz"))
        XCTAssertTrue(category.containsGenre("Blues"))
        XCTAssertGreaterThan(category.lastModifiedDate, initialDate)
    }
    
    // MARK: - Test Combined Operations
    
    func testContainsArtistOrGenre() throws {
        var category = MusicCategory(name: "Test Category")
        category.addArtist("Spyro Gyra")
        category.addGenre("Jazz")
        
        XCTAssertTrue(category.containsArtistOrGenre(artistName: "Spyro Gyra", genreName: "Classical"))
        XCTAssertTrue(category.containsArtistOrGenre(artistName: "Unknown Artist", genreName: "Jazz"))
        XCTAssertTrue(category.containsArtistOrGenre(artistName: "spyro gyra", genreName: "jazz"))
        XCTAssertFalse(category.containsArtistOrGenre(artistName: "Unknown Artist", genreName: "Classical"))
    }
    
    func testUpdateName() throws {
        var category = MusicCategory(name: "Original Name")
        let initialDate = category.lastModifiedDate
        
        Thread.sleep(forTimeInterval: 0.001)
        
        category.updateName("New Name")
        
        XCTAssertEqual(category.name, "New Name")
        XCTAssertGreaterThan(category.lastModifiedDate, initialDate)
    }
    
    func testTotalItems() throws {
        var category = MusicCategory(name: "Test Category")
        
        XCTAssertEqual(category.totalItems, 0)
        
        category.addArtist("Artist 1")
        category.addArtist("Artist 2")
        XCTAssertEqual(category.totalItems, 2)
        
        category.addGenre("Genre 1")
        XCTAssertEqual(category.totalItems, 3)
        
        category.removeArtist("Artist 1")
        XCTAssertEqual(category.totalItems, 2)
    }
    
    // MARK: - Test Convenience Factory Methods
    
    func testWithArtists() throws {
        let category = MusicCategory.withArtists(name: "Smooth Jazz", artistNames: ["Spyro Gyra", "Rippingtons"])
        
        XCTAssertEqual(category.name, "Smooth Jazz")
        XCTAssertEqual(category.artists.count, 2)
        XCTAssertTrue(category.genres.isEmpty)
        XCTAssertTrue(category.containsArtist("Spyro Gyra"))
        XCTAssertTrue(category.containsArtist("Rippingtons"))
    }
    
    func testWithGenres() throws {
        let category = MusicCategory.withGenres(name: "Electronic", genreNames: ["House", "Techno", "Ambient"])
        
        XCTAssertEqual(category.name, "Electronic")
        XCTAssertTrue(category.artists.isEmpty)
        XCTAssertEqual(category.genres.count, 3)
        XCTAssertTrue(category.containsGenre("House"))
        XCTAssertTrue(category.containsGenre("Techno"))
        XCTAssertTrue(category.containsGenre("Ambient"))
    }
    
    func testWithArtistsAndGenres() throws {
        let category = MusicCategory.withArtistsAndGenres(
            name: "Mixed Category",
            artistNames: ["Artist 1", "Artist 2"],
            genreNames: ["Genre 1", "Genre 2"]
        )
        
        XCTAssertEqual(category.name, "Mixed Category")
        XCTAssertEqual(category.artists.count, 2)
        XCTAssertEqual(category.genres.count, 2)
        XCTAssertEqual(category.totalItems, 4)
    }
    
    // MARK: - Test Codable Conformance
    
    func testCodableEncodeDecode() throws {
        let originalCategory = MusicCategory.withArtistsAndGenres(
            name: "Test Category",
            artistNames: ["Artist 1", "Artist 2"],
            genreNames: ["Genre 1", "Genre 2"]
        )
        
        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalCategory)
        
        // Decode
        let decoder = JSONDecoder()
        let decodedCategory = try decoder.decode(MusicCategory.self, from: data)
        
        // Verify
        XCTAssertEqual(originalCategory.id, decodedCategory.id)
        XCTAssertEqual(originalCategory.name, decodedCategory.name)
        XCTAssertEqual(originalCategory.artists.count, decodedCategory.artists.count)
        XCTAssertEqual(originalCategory.genres.count, decodedCategory.genres.count)
        XCTAssertEqual(originalCategory.totalItems, decodedCategory.totalItems)
    }
    
    // MARK: - Test Edge Cases
    
    func testEmptyStringHandling() throws {
        var category = MusicCategory(name: "Test Category")
        
        // Adding empty strings should be handled gracefully by the UI layer
        // But the model should accept them if passed
        category.addArtist("")
        category.addGenre("")
        
        XCTAssertEqual(category.artists.count, 1)
        XCTAssertEqual(category.genres.count, 1)
        XCTAssertTrue(category.containsArtist(""))
        XCTAssertTrue(category.containsGenre(""))
    }
    
    func testSpecialCharacters() throws {
        var category = MusicCategory(name: "Test Category")
        
        category.addArtist("Ñiño & the Señoritas")
        category.addGenre("Post-Rock/Math Rock")
        
        XCTAssertTrue(category.containsArtist("Ñiño & the Señoritas"))
        XCTAssertTrue(category.containsGenre("Post-Rock/Math Rock"))
    }
}
