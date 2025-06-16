//
//  CategoryDataStore.swift
//  Playlists
//
//  Created by Benjamin Day on 6/16/25.
//

import Foundation
import SwiftUI

/// Data store for managing music categories with persistence
class CategoryDataStore: ObservableObject {
    @Published var categories: [MusicCategory] = []
    @Published var isLoaded: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let categoriesKey = "SavedMusicCategories"
    private var isTestMode: Bool = false
    
    init() {
        load()
    }
    
    /// Initializer for testing with predefined categories
    init(testCategories: [MusicCategory]) {
        isTestMode = true
        categories = testCategories
        isLoaded = true
    }
    
    // MARK: - Category Management
    
    /// Adds a new category to the store
    func addCategory(_ category: MusicCategory) {
        // Check if category with same name already exists
        if !categories.contains(where: { $0.name.lowercased() == category.name.lowercased() }) {
            categories.append(category)
            save()
        }
    }
    
    /// Removes a category from the store
    func removeCategory(_ category: MusicCategory) {
        categories.removeAll { $0.id == category.id }
        save()
    }
    
    /// Removes categories at specified indices
    func removeCategories(at indices: IndexSet) {
        categories.remove(atOffsets: indices)
        save()
    }
    
    /// Updates an existing category
    func updateCategory(_ category: MusicCategory) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = category
            save()
        }
    }
    
    /// Finds a category by name (case-insensitive)
    func findCategory(byName name: String) -> MusicCategory? {
        return categories.first { $0.name.lowercased() == name.lowercased() }
    }
    
    /// Finds a category by ID
    func findCategory(byId id: UUID) -> MusicCategory? {
        return categories.first { $0.id == id }
    }
    
    /// Returns categories that contain the specified artist
    func categoriesContaining(artist: String) -> [MusicCategory] {
        return categories.filter { $0.containsArtist(artist) }
    }
    
    /// Returns categories that contain the specified genre
    func categoriesContaining(genre: String) -> [MusicCategory] {
        return categories.filter { $0.containsGenre(genre) }
    }
    
    /// Returns categories that contain either the artist or genre
    func categoriesContaining(artist: String, genre: String) -> [MusicCategory] {
        return categories.filter { $0.containsArtistOrGenre(artistName: artist, genreName: genre) }
    }
    
    /// Returns all category names
    var categoryNames: [String] {
        return categories.map { $0.name }
    }
    
    /// Returns the total number of categories
    var categoryCount: Int {
        return categories.count
    }
    
    /// Checks if a category name already exists (case-insensitive)
    func categoryNameExists(_ name: String) -> Bool {
        return categories.contains { $0.name.lowercased() == name.lowercased() }
    }
    
    // MARK: - Persistence
    
    /// Loads categories from UserDefaults
    private func load() {
        guard !isTestMode else { return }
        
        if let data = userDefaults.data(forKey: categoriesKey) {
            do {
                let decoder = JSONDecoder()
                categories = try decoder.decode([MusicCategory].self, from: data)
                isLoaded = true
            } catch {
                print("Error loading categories: \(error)")
                categories = []
                isLoaded = true
            }
        } else {
            // First time setup - create some default categories
            createDefaultCategories()
            isLoaded = true
        }
    }
    
    /// Saves categories to UserDefaults
    private func save() {
        guard !isTestMode else { return }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(categories)
            userDefaults.set(data, forKey: categoriesKey)
        } catch {
            print("Error saving categories: \(error)")
        }
    }
    
    /// Creates default categories for first-time users
    private func createDefaultCategories() {
        let smoothJazz = MusicCategory.withArtists(
            name: "Smooth Jazz",
            artistNames: ["Everette Harp", "Spyro Gyra", "Rippingtons", "David Benoit"]
        )
        
        let classicalPiano = MusicCategory.withGenres(
            name: "Classical Piano",
            genreNames: ["Classical", "Piano"]
        )
        
        categories = [smoothJazz, classicalPiano]
        save()
    }
    
    /// Clears all categories (primarily for testing)
    func clearAllCategories() {
        categories.removeAll()
        save()
    }
    
    /// Resets to default categories
    func resetToDefaults() {
        clearAllCategories()
        createDefaultCategories()
    }
}
