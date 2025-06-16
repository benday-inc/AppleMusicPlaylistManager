//
//  CategoryDataStoreTests.swift
//  PlaylistsTests
//
//  Created by Benjamin Day on 6/16/25.
//

import XCTest
@testable import Playlists

final class CategoryDataStoreTests: XCTestCase {
    
    var dataStore: CategoryDataStore!
    
    override func setUpWithError() throws {
        // Create test data store with predefined categories
        let testCategories = [
            MusicCategory.withArtists(name: "Smooth Jazz", artistNames: ["Spyro Gyra", "Rippingtons"]),
            MusicCategory.withGenres(name: "Classical", genreNames: ["Classical", "Piano"]),
            MusicCategory.withArtistsAndGenres(
                name: "Mixed",
                artistNames: ["Artist 1"],
                genreNames: ["Rock"]
            )
        ]
        dataStore = CategoryDataStore(testCategories: testCategories)
    }
    
    override func tearDownWithError() throws {
        dataStore = nil
    }
    
    // MARK: - Test Initialization
    
    func testInitialization() throws {
        XCTAssertTrue(dataStore.isLoaded)
        XCTAssertEqual(dataStore.categoryCount, 3)
        XCTAssertEqual(dataStore.categoryNames.count, 3)
    }
    
    func testEmptyInitialization() throws {
        let emptyDataStore = CategoryDataStore(testCategories: [])
        XCTAssertTrue(emptyDataStore.isLoaded)
        XCTAssertEqual(emptyDataStore.categoryCount, 0)
        XCTAssertTrue(emptyDataStore.categoryNames.isEmpty)
    }
    
    // MARK: - Test Category Management
    
    func testAddCategory() throws {
        let newCategory = MusicCategory(name: "New Category")
        let initialCount = dataStore.categoryCount
        
        dataStore.addCategory(newCategory)
        
        XCTAssertEqual(dataStore.categoryCount, initialCount + 1)
        XCTAssertNotNil(dataStore.findCategory(byName: "New Category"))
        XCTAssertTrue(dataStore.categoryNames.contains("New Category"))
    }
    
    func testAddDuplicateCategory() throws {
        let duplicateCategory = MusicCategory(name: "Smooth Jazz") // Already exists
        let initialCount = dataStore.categoryCount
        
        dataStore.addCategory(duplicateCategory)
        
        // Should not add duplicate
        XCTAssertEqual(dataStore.categoryCount, initialCount)
    }
    
    func testAddCategoryCaseInsensitive() throws {
        let duplicateCategory = MusicCategory(name: "SMOOTH JAZZ") // Case different
        let initialCount = dataStore.categoryCount
        
        dataStore.addCategory(duplicateCategory)
        
        // Should not add duplicate (case insensitive)
        XCTAssertEqual(dataStore.categoryCount, initialCount)
    }
    
    func testRemoveCategory() throws {
        guard let categoryToRemove = dataStore.findCategory(byName: "Smooth Jazz") else {
            XCTFail("Test category not found")
            return
        }
        
        let initialCount = dataStore.categoryCount
        dataStore.removeCategory(categoryToRemove)
        
        XCTAssertEqual(dataStore.categoryCount, initialCount - 1)
        XCTAssertNil(dataStore.findCategory(byName: "Smooth Jazz"))
        XCTAssertFalse(dataStore.categoryNames.contains("Smooth Jazz"))
    }
    
    func testRemoveCategoriesAtIndices() throws {
        let initialCount = dataStore.categoryCount
        let indicesToRemove = IndexSet([0, 2]) // Remove first and third
        
        dataStore.removeCategories(at: indicesToRemove)
        
        XCTAssertEqual(dataStore.categoryCount, initialCount - 2)
    }
    
    func testUpdateCategory() throws {
        guard var categoryToUpdate = dataStore.findCategory(byName: "Smooth Jazz") else {
            XCTFail("Test category not found")
            return
        }
        
        categoryToUpdate.addArtist("David Benoit")
        dataStore.updateCategory(categoryToUpdate)
        
        let updatedCategory = dataStore.findCategory(byName: "Smooth Jazz")
        XCTAssertNotNil(updatedCategory)
        XCTAssertTrue(updatedCategory!.containsArtist("David Benoit"))
    }
    
    // MARK: - Test Search and Query Operations
    
    func testFindCategoryByName() throws {
        let foundCategory = dataStore.findCategory(byName: "Smooth Jazz")
        XCTAssertNotNil(foundCategory)
        XCTAssertEqual(foundCategory?.name, "Smooth Jazz")
        
        let notFoundCategory = dataStore.findCategory(byName: "Nonexistent")
        XCTAssertNil(notFoundCategory)
    }
    
    func testFindCategoryByNameCaseInsensitive() throws {
        let foundCategory = dataStore.findCategory(byName: "SMOOTH JAZZ")
        XCTAssertNotNil(foundCategory)
        XCTAssertEqual(foundCategory?.name, "Smooth Jazz")
    }
    
    func testFindCategoryById() throws {
        guard let originalCategory = dataStore.findCategory(byName: "Smooth Jazz") else {
            XCTFail("Test category not found")
            return
        }
        
        let foundCategory = dataStore.findCategory(byId: originalCategory.id)
        XCTAssertNotNil(foundCategory)
        XCTAssertEqual(foundCategory?.id, originalCategory.id)
        
        let notFoundCategory = dataStore.findCategory(byId: UUID())
        XCTAssertNil(notFoundCategory)
    }
    
    func testCategoriesContainingArtist() throws {
        let categories = dataStore.categoriesContaining(artist: "Spyro Gyra")
        XCTAssertEqual(categories.count, 1)
        XCTAssertEqual(categories.first?.name, "Smooth Jazz")
        
        let noneFound = dataStore.categoriesContaining(artist: "Unknown Artist")
        XCTAssertTrue(noneFound.isEmpty)
    }
    
    func testCategoriesContainingGenre() throws {
        let categories = dataStore.categoriesContaining(genre: "Classical")
        XCTAssertEqual(categories.count, 1)
        XCTAssertEqual(categories.first?.name, "Classical")
        
        let noneFound = dataStore.categoriesContaining(genre: "Unknown Genre")
        XCTAssertTrue(noneFound.isEmpty)
    }
    
    func testCategoriesContainingArtistOrGenre() throws {
        // Should find category that contains the artist
        let artistMatch = dataStore.categoriesContaining(artist: "Spyro Gyra", genre: "Unknown Genre")
        XCTAssertEqual(artistMatch.count, 1)
        XCTAssertEqual(artistMatch.first?.name, "Smooth Jazz")
        
        // Should find category that contains the genre
        let genreMatch = dataStore.categoriesContaining(artist: "Unknown Artist", genre: "Classical")
        XCTAssertEqual(genreMatch.count, 1)
        XCTAssertEqual(genreMatch.first?.name, "Classical")
        
        // Should find category that contains both
        let bothMatch = dataStore.categoriesContaining(artist: "Artist 1", genre: "Rock")
        XCTAssertEqual(bothMatch.count, 1)
        XCTAssertEqual(bothMatch.first?.name, "Mixed")
        
        // Should find nothing
        let noneFound = dataStore.categoriesContaining(artist: "Unknown Artist", genre: "Unknown Genre")
        XCTAssertTrue(noneFound.isEmpty)
    }
    
    func testCategoryNameExists() throws {
        XCTAssertTrue(dataStore.categoryNameExists("Smooth Jazz"))
        XCTAssertTrue(dataStore.categoryNameExists("SMOOTH JAZZ")) // Case insensitive
        XCTAssertFalse(dataStore.categoryNameExists("Nonexistent Category"))
    }
    
    // MARK: - Test Utility Operations
    
    func testClearAllCategories() throws {
        XCTAssertGreaterThan(dataStore.categoryCount, 0)
        
        dataStore.clearAllCategories()
        
        XCTAssertEqual(dataStore.categoryCount, 0)
        XCTAssertTrue(dataStore.categoryNames.isEmpty)
    }
    
    func testResetToDefaults() throws {
        // First clear all categories
        dataStore.clearAllCategories()
        XCTAssertEqual(dataStore.categoryCount, 0)
        
        // Reset to defaults
        dataStore.resetToDefaults()
        
        // Should have default categories
        XCTAssertGreaterThan(dataStore.categoryCount, 0)
        XCTAssertNotNil(dataStore.findCategory(byName: "Smooth Jazz"))
        XCTAssertNotNil(dataStore.findCategory(byName: "Classical Piano"))
    }
    
    // MARK: - Test Properties
    
    func testCategoryNames() throws {
        let names = dataStore.categoryNames
        XCTAssertEqual(names.count, 3)
        XCTAssertTrue(names.contains("Smooth Jazz"))
        XCTAssertTrue(names.contains("Classical"))
        XCTAssertTrue(names.contains("Mixed"))
    }
    
    func testCategoryCount() throws {
        XCTAssertEqual(dataStore.categoryCount, 3)
        
        let newCategory = MusicCategory(name: "Test")
        dataStore.addCategory(newCategory)
        XCTAssertEqual(dataStore.categoryCount, 4)
        
        dataStore.removeCategory(newCategory)
        XCTAssertEqual(dataStore.categoryCount, 3)
    }
    
    // MARK: - Test Edge Cases
    
    func testRemoveNonexistentCategory() throws {
        let nonexistentCategory = MusicCategory(name: "Nonexistent")
        let initialCount = dataStore.categoryCount
        
        dataStore.removeCategory(nonexistentCategory)
        
        // Should not change count
        XCTAssertEqual(dataStore.categoryCount, initialCount)
    }
    
    func testUpdateNonexistentCategory() throws {
        let nonexistentCategory = MusicCategory(name: "Nonexistent")
        let initialCount = dataStore.categoryCount
        
        dataStore.updateCategory(nonexistentCategory)
        
        // Should not change count
        XCTAssertEqual(dataStore.categoryCount, initialCount)
    }
    
    func testEmptyStringSearch() throws {
        let categories = dataStore.categoriesContaining(artist: "")
        // This depends on implementation - if empty strings are added to test data
        // For now, assuming no empty strings in test data
        XCTAssertTrue(categories.isEmpty)
    }
    
    // MARK: - Test Performance
    
    func testPerformanceAddManyCategories() throws {
        measure {
            for i in 0..<1000 {
                let category = MusicCategory(name: "Category \(i)")
                dataStore.addCategory(category)
            }
        }
    }
    
    func testPerformanceSearchCategories() throws {
        // Add many categories first
        for i in 0..<100 {
            let category = MusicCategory.withArtists(name: "Category \(i)", artistNames: ["Artist \(i)"])
            dataStore.addCategory(category)
        }
        
        measure {
            for i in 0..<100 {
                _ = dataStore.categoriesContaining(artist: "Artist \(i)")
            }
        }
    }
}
