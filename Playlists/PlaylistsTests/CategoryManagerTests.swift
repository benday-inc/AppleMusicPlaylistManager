//
//  CategoryManagerTests.swift
//  PlaylistsTests
//
//  Created by Benjamin Day on 6/16/25.
//

import XCTest
@testable import Playlists

final class CategoryManagerTests: XCTestCase {
    
    var categoryManager: CategoryManager!
    
    override func setUpWithError() throws {
        // Create test data store with predefined categories
        let testCategories = [
            MusicCategory.withArtists(name: "Smooth Jazz", artistNames: ["Spyro Gyra", "Rippingtons"]),
            MusicCategory.withGenres(name: "Classical", genreNames: ["Classical", "Piano"])
        ]
        let dataStore = CategoryDataStore(testCategories: testCategories)
        categoryManager = CategoryManager(dataStore: dataStore)
    }
    
    override func tearDownWithError() throws {
        categoryManager = nil
    }
    
    // MARK: - Test Category Creation
    
    func testCreateCategory() throws {
        let result = categoryManager.createCategory(name: "New Category")
        
        switch result {
        case .success(let category):
            XCTAssertEqual(category.name, "New Category")
            XCTAssertTrue(category.isEmpty)
            XCTAssertNotNil(categoryManager.getCategory(byName: "New Category"))
        case .failure(let error):
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testCreateCategoryWithEmptyName() throws {
        let result = categoryManager.createCategory(name: "")
        
        switch result {
        case .success:
            XCTFail("Should have failed with empty name")
        case .failure(let error):
            XCTAssertEqual(error, CategoryError.emptyName)
        }
    }
    
    func testCreateCategoryWithWhitespaceOnlyName() throws {
        let result = categoryManager.createCategory(name: "   ")
        
        switch result {
        case .success:
            XCTFail("Should have failed with whitespace-only name")
        case .failure(let error):
            XCTAssertEqual(error, CategoryError.emptyName)
        }
    }
    
    func testCreateCategoryWithDuplicateName() throws {
        let result = categoryManager.createCategory(name: "Smooth Jazz") // Already exists
        
        switch result {
        case .success:
            XCTFail("Should have failed with duplicate name")
        case .failure(let error):
            XCTAssertEqual(error, CategoryError.duplicateName)
        }
    }
    
    func testCreateCategoryWithArtists() throws {
        let result = categoryManager.createCategory(name: "Jazz Fusion", artists: ["Weather Report", "Mahavishnu Orchestra"])
        
        switch result {
        case .success(let category):
            XCTAssertEqual(category.name, "Jazz Fusion")
            XCTAssertEqual(category.artists.count, 2)
            XCTAssertTrue(category.containsArtist("Weather Report"))
            XCTAssertTrue(category.containsArtist("Mahavishnu Orchestra"))
            XCTAssertTrue(category.genres.isEmpty)
        case .failure(let error):
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testCreateCategoryWithGenres() throws {
        let result = categoryManager.createCategory(name: "Electronic", genres: ["House", "Techno", "Ambient"])
        
        switch result {
        case .success(let category):
            XCTAssertEqual(category.name, "Electronic")
            XCTAssertEqual(category.genres.count, 3)
            XCTAssertTrue(category.containsGenre("House"))
            XCTAssertTrue(category.containsGenre("Techno"))
            XCTAssertTrue(category.containsGenre("Ambient"))
            XCTAssertTrue(category.artists.isEmpty)
        case .failure(let error):
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testCreateCategoryWithArtistsAndGenres() throws {
        let result = categoryManager.createCategory(
            name: "Progressive Rock",
            artists: ["Pink Floyd", "Yes"],
            genres: ["Progressive Rock", "Art Rock"]
        )
        
        switch result {
        case .success(let category):
            XCTAssertEqual(category.name, "Progressive Rock")
            XCTAssertEqual(category.artists.count, 2)
            XCTAssertEqual(category.genres.count, 2)
            XCTAssertEqual(category.totalItems, 4)
        case .failure(let error):
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Test Artist Management
    
    func testAddArtistToCategory() throws {
        guard let category = categoryManager.getCategory(byName: "Smooth Jazz") else {
            XCTFail("Test category not found")
            return
        }
        
        let result = categoryManager.addArtist("David Benoit", to: category.id)
        
        switch result {
        case .success:
            let updatedCategory = categoryManager.getCategory(byId: category.id)
            XCTAssertNotNil(updatedCategory)
            XCTAssertTrue(updatedCategory!.containsArtist("David Benoit"))
        case .failure(let error):
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testAddArtistToNonexistentCategory() throws {
        let result = categoryManager.addArtist("Artist Name", to: UUID())
        
        switch result {
        case .success:
            XCTFail("Should have failed with category not found")
        case .failure(let error):
            XCTAssertEqual(error, CategoryError.categoryNotFound)
        }
    }
    
    func testAddEmptyArtistName() throws {
        guard let category = categoryManager.getCategory(byName: "Smooth Jazz") else {
            XCTFail("Test category not found")
            return
        }
        
        let result = categoryManager.addArtist("", to: category.id)
        
        switch result {
        case .success:
            XCTFail("Should have failed with empty artist name")
        case .failure(let error):
            XCTAssertEqual(error, CategoryError.emptyArtistName)
        }
    }
    
    func testRemoveArtistFromCategory() throws {
        guard let category = categoryManager.getCategory(byName: "Smooth Jazz") else {
            XCTFail("Test category not found")
            return
        }
        
        let result = categoryManager.removeArtist("Spyro Gyra", from: category.id)
        
        switch result {
        case .success:
            let updatedCategory = categoryManager.getCategory(byId: category.id)
            XCTAssertNotNil(updatedCategory)
            XCTAssertFalse(updatedCategory!.containsArtist("Spyro Gyra"))
        case .failure(let error):
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Test Genre Management
    
    func testAddGenreToCategory() throws {
        guard let category = categoryManager.getCategory(byName: "Classical") else {
            XCTFail("Test category not found")
            return
        }
        
        let result = categoryManager.addGenre("Chamber Music", to: category.id)
        
        switch result {
        case .success:
            let updatedCategory = categoryManager.getCategory(byId: category.id)
            XCTAssertNotNil(updatedCategory)
            XCTAssertTrue(updatedCategory!.containsGenre("Chamber Music"))
        case .failure(let error):
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testAddGenreToNonexistentCategory() throws {
        let result = categoryManager.addGenre("Genre Name", to: UUID())
        
        switch result {
        case .success:
            XCTFail("Should have failed with category not found")
        case .failure(let error):
            XCTAssertEqual(error, CategoryError.categoryNotFound)
        }
    }
    
    func testAddEmptyGenreName() throws {
        guard let category = categoryManager.getCategory(byName: "Classical") else {
            XCTFail("Test category not found")
            return
        }
        
        let result = categoryManager.addGenre("   ", to: category.id)
        
        switch result {
        case .success:
            XCTFail("Should have failed with empty genre name")
        case .failure(let error):
            XCTAssertEqual(error, CategoryError.emptyGenreName)
        }
    }
    
    func testRemoveGenreFromCategory() throws {
        guard let category = categoryManager.getCategory(byName: "Classical") else {
            XCTFail("Test category not found")
            return
        }
        
        let result = categoryManager.removeGenre("Piano", from: category.id)
        
        switch result {
        case .success:
            let updatedCategory = categoryManager.getCategory(byId: category.id)
            XCTAssertNotNil(updatedCategory)
            XCTAssertFalse(updatedCategory!.containsGenre("Piano"))
        case .failure(let error):
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Test Category Management
    
    func testUpdateCategoryName() throws {
        guard let category = categoryManager.getCategory(byName: "Smooth Jazz") else {
            XCTFail("Test category not found")
            return
        }
        
        let result = categoryManager.updateCategoryName(category.id, newName: "Contemporary Jazz")
        
        switch result {
        case .success:
            XCTAssertNil(categoryManager.getCategory(byName: "Smooth Jazz"))
            XCTAssertNotNil(categoryManager.getCategory(byName: "Contemporary Jazz"))
        case .failure(let error):
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testUpdateCategoryNameToEmpty() throws {
        guard let category = categoryManager.getCategory(byName: "Smooth Jazz") else {
            XCTFail("Test category not found")
            return
        }
        
        let result = categoryManager.updateCategoryName(category.id, newName: "")
        
        switch result {
        case .success:
            XCTFail("Should have failed with empty name")
        case .failure(let error):
            XCTAssertEqual(error, CategoryError.emptyName)
        }
    }
    
    func testUpdateCategoryNameToDuplicate() throws {
        guard let category = categoryManager.getCategory(byName: "Smooth Jazz") else {
            XCTFail("Test category not found")
            return
        }
        
        let result = categoryManager.updateCategoryName(category.id, newName: "Classical") // Already exists
        
        switch result {
        case .success:
            XCTFail("Should have failed with duplicate name")
        case .failure(let error):
            XCTAssertEqual(error, CategoryError.duplicateName)
        }
    }
    
    func testDeleteCategory() throws {
        guard let category = categoryManager.getCategory(byName: "Smooth Jazz") else {
            XCTFail("Test category not found")
            return
        }
        
        let initialCount = categoryManager.allCategories.count
        let result = categoryManager.deleteCategory(category.id)
        
        switch result {
        case .success:
            XCTAssertEqual(categoryManager.allCategories.count, initialCount - 1)
            XCTAssertNil(categoryManager.getCategory(byName: "Smooth Jazz"))
        case .failure(let error):
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testDeleteNonexistentCategory() throws {
        let result = categoryManager.deleteCategory(UUID())
        
        switch result {
        case .success:
            XCTFail("Should have failed with category not found")
        case .failure(let error):
            XCTAssertEqual(error, CategoryError.categoryNotFound)
        }
    }
    
    // MARK: - Test Query Operations
    
    func testGetAllCategories() throws {
        let categories = categoryManager.allCategories
        XCTAssertEqual(categories.count, 2)
        
        let names = categories.map { $0.name }
        XCTAssertTrue(names.contains("Smooth Jazz"))
        XCTAssertTrue(names.contains("Classical"))
    }
    
    func testGetCategoryById() throws {
        guard let originalCategory = categoryManager.getCategory(byName: "Smooth Jazz") else {
            XCTFail("Test category not found")
            return
        }
        
        let foundCategory = categoryManager.getCategory(byId: originalCategory.id)
        XCTAssertNotNil(foundCategory)
        XCTAssertEqual(foundCategory?.id, originalCategory.id)
        
        let notFound = categoryManager.getCategory(byId: UUID())
        XCTAssertNil(notFound)
    }
    
    func testGetCategoryByName() throws {
        let foundCategory = categoryManager.getCategory(byName: "Smooth Jazz")
        XCTAssertNotNil(foundCategory)
        XCTAssertEqual(foundCategory?.name, "Smooth Jazz")
        
        let notFound = categoryManager.getCategory(byName: "Nonexistent")
        XCTAssertNil(notFound)
    }
    
    func testMatchingCategories() throws {
        let matchingCategories = categoryManager.matchingCategories(for: "Spyro Gyra", genre: "Unknown")
        XCTAssertEqual(matchingCategories.count, 1)
        XCTAssertEqual(matchingCategories.first?.name, "Smooth Jazz")
        
        let genreMatches = categoryManager.matchingCategories(for: "Unknown Artist", genre: "Classical")
        XCTAssertEqual(genreMatches.count, 1)
        XCTAssertEqual(genreMatches.first?.name, "Classical")
        
        let noMatches = categoryManager.matchingCategories(for: "Unknown Artist", genre: "Unknown Genre")
        XCTAssertTrue(noMatches.isEmpty)
    }
    
    func testIsMediaItemInCategory() throws {
        guard let category = categoryManager.getCategory(byName: "Smooth Jazz") else {
            XCTFail("Test category not found")
            return
        }
        
        XCTAssertTrue(categoryManager.isMediaItemInCategory(category.id, artist: "Spyro Gyra", genre: "Unknown"))
        XCTAssertFalse(categoryManager.isMediaItemInCategory(category.id, artist: "Unknown Artist", genre: "Unknown"))
        XCTAssertFalse(categoryManager.isMediaItemInCategory(UUID(), artist: "Spyro Gyra", genre: "Unknown"))
    }
    
    // MARK: - Test Statistics and Validation
    
    func testGetCategoryStatistics() throws {
        let stats = categoryManager.getCategoryStatistics()
        
        XCTAssertEqual(stats.totalCategories, 2)
        XCTAssertEqual(stats.totalArtists, 2) // Spyro Gyra, Rippingtons
        XCTAssertEqual(stats.totalGenres, 2) // Classical, Piano
        XCTAssertEqual(stats.emptyCategories, 0)
        XCTAssertEqual(stats.averageItemsPerCategory, 2.0) // (2 + 2) / 2
    }
    
    func testGetCategoryStatisticsWithEmptyCategory() throws {
        _ = categoryManager.createCategory(name: "Empty Category")
        let stats = categoryManager.getCategoryStatistics()
        
        XCTAssertEqual(stats.totalCategories, 3)
        XCTAssertEqual(stats.emptyCategories, 1)
    }
    
    func testValidateCategories() throws {
        let issues = categoryManager.validateCategories()
        XCTAssertTrue(issues.isEmpty) // Should have no issues with clean test data
    }
    
    func testValidateCategoriesWithIssues() throws {
        // Create a category with issues
        var problematicCategory = MusicCategory(name: "")
        problematicCategory.addArtist("Artist 1")
        problematicCategory.addArtist("Artist 1") // This might create duplicate if not handled
        categoryManager.dataStore.addCategory(problematicCategory)
        
        let issues = categoryManager.validateCategories()
        XCTAssertFalse(issues.isEmpty)
        
        // Check for empty name issue
        let hasEmptyNameIssue = issues.contains { issue in
            if case .emptyName = issue { return true }
            return false
        }
        XCTAssertTrue(hasEmptyNameIssue)
    }
    
    // MARK: - Test Edge Cases
    
    func testTrimsWhitespaceInNames() throws {
        let result = categoryManager.createCategory(name: "  Test Category  ")
        
        switch result {
        case .success(let category):
            XCTAssertEqual(category.name, "Test Category")
        case .failure(let error):
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testTrimsWhitespaceInArtistAndGenreNames() throws {
        guard let category = categoryManager.getCategory(byName: "Smooth Jazz") else {
            XCTFail("Test category not found")
            return
        }
        
        let artistResult = categoryManager.addArtist("  Trimmed Artist  ", to: category.id)
        XCTAssertTrue(artistResult.isSuccess)
        
        let genreResult = categoryManager.addGenre("  Trimmed Genre  ", to: category.id)
        XCTAssertTrue(genreResult.isSuccess)
        
        let updatedCategory = categoryManager.getCategory(byId: category.id)
        XCTAssertNotNil(updatedCategory)
        XCTAssertTrue(updatedCategory!.containsArtist("Trimmed Artist"))
        XCTAssertTrue(updatedCategory!.containsGenre("Trimmed Genre"))
    }
    
    // MARK: - Test Performance
    
    func testPerformanceCreateManyCategories() throws {
        measure {
            for i in 0..<100 {
                _ = categoryManager.createCategory(name: "Performance Test \(i)")
            }
        }
    }
    
    func testPerformanceQueryManyCategories() throws {
        // First create many categories
        for i in 0..<100 {
            _ = categoryManager.createCategory(name: "Query Test \(i)", artists: ["Artist \(i)"])
        }
        
        measure {
            for i in 0..<100 {
                _ = categoryManager.matchingCategories(for: "Artist \(i)", genre: "Unknown")
            }
        }
    }
}

// MARK: - Result Extension for Testing

extension Result {
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
}
