//
//  CategoryManager.swift
//  Playlists
//
//  Created by Benjamin Day on 6/16/25.
//

import Foundation

/// Service layer for managing music categories and playlist generation
class CategoryManager: ObservableObject {
    @Published private(set) var dataStore: CategoryDataStore
    
    init(dataStore: CategoryDataStore = CategoryDataStore()) {
        self.dataStore = dataStore
    }
    
    // MARK: - Category Operations
    
    /// Creates a new category with the given name
    func createCategory(name: String) -> Result<MusicCategory, CategoryError> {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validate name
        guard !trimmedName.isEmpty else {
            return .failure(.emptyName)
        }
        
        guard !dataStore.categoryNameExists(trimmedName) else {
            return .failure(.duplicateName)
        }
        
        let category = MusicCategory(name: trimmedName)
        dataStore.addCategory(category)
        return .success(category)
    }
    
    /// Creates a category with artists
    func createCategory(name: String, artists: [String]) -> Result<MusicCategory, CategoryError> {
        switch createCategory(name: name) {
        case .success(var category):
            for artist in artists {
                category.addArtist(artist)
            }
            dataStore.updateCategory(category)
            return .success(category)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// Creates a category with genres
    func createCategory(name: String, genres: [String]) -> Result<MusicCategory, CategoryError> {
        switch createCategory(name: name) {
        case .success(var category):
            for genre in genres {
                category.addGenre(genre)
            }
            dataStore.updateCategory(category)
            return .success(category)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// Creates a category with both artists and genres
    func createCategory(name: String, artists: [String], genres: [String]) -> Result<MusicCategory, CategoryError> {
        switch createCategory(name: name) {
        case .success(var category):
            for artist in artists {
                category.addArtist(artist)
            }
            for genre in genres {
                category.addGenre(genre)
            }
            dataStore.updateCategory(category)
            return .success(category)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// Adds an artist to an existing category
    func addArtist(_ artistName: String, to categoryId: UUID) -> Result<Void, CategoryError> {
        guard var category = dataStore.findCategory(byId: categoryId) else {
            return .failure(.categoryNotFound)
        }
        
        let trimmedArtist = artistName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedArtist.isEmpty else {
            return .failure(.emptyArtistName)
        }
        
        category.addArtist(trimmedArtist)
        dataStore.updateCategory(category)
        return .success(())
    }
    
    /// Adds a genre to an existing category
    func addGenre(_ genreName: String, to categoryId: UUID) -> Result<Void, CategoryError> {
        guard var category = dataStore.findCategory(byId: categoryId) else {
            return .failure(.categoryNotFound)
        }
        
        let trimmedGenre = genreName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedGenre.isEmpty else {
            return .failure(.emptyGenreName)
        }
        
        category.addGenre(trimmedGenre)
        dataStore.updateCategory(category)
        return .success(())
    }
    
    /// Removes an artist from a category
    func removeArtist(_ artistName: String, from categoryId: UUID) -> Result<Void, CategoryError> {
        guard var category = dataStore.findCategory(byId: categoryId) else {
            return .failure(.categoryNotFound)
        }
        
        category.removeArtist(artistName)
        dataStore.updateCategory(category)
        return .success(())
    }
    
    /// Removes a genre from a category
    func removeGenre(_ genreName: String, from categoryId: UUID) -> Result<Void, CategoryError> {
        guard var category = dataStore.findCategory(byId: categoryId) else {
            return .failure(.categoryNotFound)
        }
        
        category.removeGenre(genreName)
        dataStore.updateCategory(category)
        return .success(())
    }
    
    /// Updates the name of a category
    func updateCategoryName(_ categoryId: UUID, newName: String) -> Result<Void, CategoryError> {
        guard var category = dataStore.findCategory(byId: categoryId) else {
            return .failure(.categoryNotFound)
        }
        
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            return .failure(.emptyName)
        }
        
        // Check if another category already has this name
        if let existingCategory = dataStore.findCategory(byName: trimmedName),
           existingCategory.id != categoryId {
            return .failure(.duplicateName)
        }
        
        category.updateName(trimmedName)
        dataStore.updateCategory(category)
        return .success(())
    }
    
    /// Deletes a category
    func deleteCategory(_ categoryId: UUID) -> Result<Void, CategoryError> {
        guard let category = dataStore.findCategory(byId: categoryId) else {
            return .failure(.categoryNotFound)
        }
        
        dataStore.removeCategory(category)
        return .success(())
    }
    
    // MARK: - Query Operations
    
    /// Gets all categories
    var allCategories: [MusicCategory] {
        return dataStore.categories
    }
    
    /// Gets a category by ID
    func getCategory(byId id: UUID) -> MusicCategory? {
        return dataStore.findCategory(byId: id)
    }
    
    /// Gets a category by name
    func getCategory(byName name: String) -> MusicCategory? {
        return dataStore.findCategory(byName: name)
    }
    
    /// Checks if a media item matches any category
    func matchingCategories(for artist: String, genre: String) -> [MusicCategory] {
        return dataStore.categoriesContaining(artist: artist, genre: genre)
    }
    
    /// Checks if a media item belongs to a specific category
    func isMediaItemInCategory(_ categoryId: UUID, artist: String, genre: String) -> Bool {
        guard let category = dataStore.findCategory(byId: categoryId) else {
            return false
        }
        return category.containsArtistOrGenre(artistName: artist, genreName: genre)
    }
    
    // MARK: - Utility Operations
    
    /// Gets statistics about all categories
    func getCategoryStatistics() -> CategoryStatistics {
        let categories = dataStore.categories
        let totalCategories = categories.count
        let totalArtists = categories.reduce(0) { $0 + $1.artists.count }
        let totalGenres = categories.reduce(0) { $0 + $1.genres.count }
        let emptyCategories = categories.filter { $0.isEmpty }.count
        
        return CategoryStatistics(
            totalCategories: totalCategories,
            totalArtists: totalArtists,
            totalGenres: totalGenres,
            emptyCategories: emptyCategories,
            averageItemsPerCategory: totalCategories > 0 ? Double(totalArtists + totalGenres) / Double(totalCategories) : 0
        )
    }
    
    /// Validates the integrity of all categories
    func validateCategories() -> [CategoryValidationIssue] {
        var issues: [CategoryValidationIssue] = []
        
        for category in dataStore.categories {
            if category.name.isEmpty {
                issues.append(.emptyName(categoryId: category.id))
            }
            
            if category.isEmpty {
                issues.append(.emptyCategory(categoryId: category.id, name: category.name))
            }
            
            // Check for duplicate artist names within the category
            let artistNames = category.artists.map { $0.value.lowercased() }
            let uniqueArtistNames = Set(artistNames)
            if artistNames.count != uniqueArtistNames.count {
                issues.append(.duplicateArtists(categoryId: category.id, name: category.name))
            }
            
            // Check for duplicate genre names within the category
            let genreNames = category.genres.map { $0.value.lowercased() }
            let uniqueGenreNames = Set(genreNames)
            if genreNames.count != uniqueGenreNames.count {
                issues.append(.duplicateGenres(categoryId: category.id, name: category.name))
            }
        }
        
        return issues
    }
}

// MARK: - Supporting Types

enum CategoryError: Error, LocalizedError {
    case emptyName
    case duplicateName
    case categoryNotFound
    case emptyArtistName
    case emptyGenreName
    
    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "Category name cannot be empty"
        case .duplicateName:
            return "A category with this name already exists"
        case .categoryNotFound:
            return "Category not found"
        case .emptyArtistName:
            return "Artist name cannot be empty"
        case .emptyGenreName:
            return "Genre name cannot be empty"
        }
    }
}

struct CategoryStatistics {
    let totalCategories: Int
    let totalArtists: Int
    let totalGenres: Int
    let emptyCategories: Int
    let averageItemsPerCategory: Double
}

enum CategoryValidationIssue {
    case emptyName(categoryId: UUID)
    case emptyCategory(categoryId: UUID, name: String)
    case duplicateArtists(categoryId: UUID, name: String)
    case duplicateGenres(categoryId: UUID, name: String)
}
