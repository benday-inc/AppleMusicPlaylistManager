//
//  PlaylistDataStore.swift
//  RandomPlaylistGenerator (iOS)
//
//  Created by Benjamin Day on 12/27/21.
//


import Foundation
import SwiftUI



class PlaylistDataStore: ObservableObject, @unchecked Sendable {
    static let shared = PlaylistDataStore()
    
    @Published var excludedGenres: [IdentifiableString] = []
    @Published var excludedArtists: [IdentifiableString] = []
    @Published var excludedAlbums: [IdentifiableString] = []
    @Published var categories: [Category] = []
    @Published var isLoaded: Bool = false
    private var isTestMode: Bool = false
    private var isLoadedCompleteGenre: Bool = false
    private var isLoadedCompleteArtist: Bool = false
    private var isLoadedCompleteAlbum: Bool = false
    private var isLoadedCategories: Bool = false
    private var isCurrentlyLoading: Bool = false
    
    private static let migrationKey = "hasCompletedICloudMigration"
    private static let dataFilenames = ["categories", "excluded-genres", "excluded-artists", "excluded-albums"]

    private init() {
        // Migrate local data to iCloud if needed, then load
        Task { @MainActor in
            if !isLoaded {
                await migrateLocalDataToICloudIfNeeded()
                await load()
            }
        }
    }
    
    init(testDataExcludedGenres: [IdentifiableString],
         testDataExcludedArtists: [IdentifiableString],
         testDataExcludedAlbums: [IdentifiableString]) {
        isTestMode = true
        excludedGenres = testDataExcludedGenres
        excludedAlbums = testDataExcludedAlbums
        excludedArtists = testDataExcludedArtists
        categories = []
        Task {
            await load()
        }
    }
    
    init(testCategories: [Category]) {
        isTestMode = true
        excludedGenres = []
        excludedAlbums = []
        excludedArtists = []
        categories = testCategories
        Task {
            await load()
        }
    }
    
    func isExcluded(item: MediaItemWrapper, playlistMode: String) -> Bool {
//        print("Checking \(playlistMode) exclusion: '\(item.artistName)'; '\(item.albumName)'; '\(item.genreName)'")
        
        if (playlistMode != AppConstants.PLAYLIST_MODE_ALL) {
//            print("Not checking excluded genres, artists, or albums in '\(playlistMode)' mode.")
            return false;
        }
        else {
            let albumAndArtist = "\(item.artistName) - \(item.albumName)"
            
            if (contains(searchInValues: excludedGenres,
                         searchForValue: item.genreName) == true) {
                return true
            }
            else if (contains(searchInValues: excludedArtists,
                         searchForValue: item.artistName) == true) {
                return true
            }
            else if (contains(searchInValues: excludedAlbums,
                         searchForValue: albumAndArtist) == true) {
                return true
            }
            else {
                return false
            }
        }
    }
    
    private func contains(searchInValues: [IdentifiableString],
                          searchForValue: String) -> Bool {
        let result = searchInValues.contains { $0.value == searchForValue }
        
        if (result == true) {
            return true
        }
        else {
            return false
        }
    }
    
    func addGenreExclusion(item: MediaItemWrapper) {
        excludedGenres.append(IdentifiableString(value: item.genreName))
        save()
    }
    
    func removeGenreExclusion(item: IdentifiableString) {
        if let index = excludedGenres.firstIndex(of: item) {
            excludedGenres.remove(at: index)
            save()
        }
    }
    
    func addArtistExclusion(item: MediaItemWrapper) {
        excludedArtists.append(IdentifiableString(value: item.artistName))
        save()
    }
    
    func removeArtistExclusion(item: IdentifiableString) {
        if let index = excludedArtists.firstIndex(of: item) {
            excludedArtists.remove(at: index)
            save()
        }
    }
    
    func addAlbumExclusion(item: MediaItemWrapper) {
        excludedAlbums.append(IdentifiableString(value: "\(item.artistName) - \(item.albumName)"))
        save()
    }
    
    func removeAlbumExclusion(item: IdentifiableString) {
        if let index = excludedAlbums.firstIndex(of: item) {
            excludedAlbums.remove(at: index)
            save()
        }
    }
    
    private func populateIsLoaded() {
        if (self.isLoadedCategories && self.isLoadedCompleteGenre && self.isLoadedCompleteArtist && self.isLoadedCompleteAlbum) {
            self.isLoaded = true
            print("all loaded")
        }
        else {
            print("not all loaded yet")
        }
    }
    
    func load() async {
        // Prevent multiple concurrent loads
        guard !isCurrentlyLoading && !isLoaded else { return }
        
        isCurrentlyLoading = true
        defer { isCurrentlyLoading = false }
        
        if isTestMode {
            await MainActor.run {
                self.isLoaded = true
            }
            return
        }

        async let categoriesResult = loadAsync(Category.self, filename: "categories")
        async let genresResult = loadAsync(IdentifiableString.self, filename: "excluded-genres")
        async let artistsResult = loadAsync(IdentifiableString.self, filename: "excluded-artists")
        async let albumsResult = loadAsync(IdentifiableString.self, filename: "excluded-albums")

        do {
            let loadedCategories = try await categoriesResult
            let loadedGenres = try await genresResult
            let loadedArtists = try await artistsResult
            let loadedAlbums = try await albumsResult

            DispatchQueue.main.async {
                self.categories = loadedCategories
                self.excludedGenres = loadedGenres
                self.excludedArtists = loadedArtists
                self.excludedAlbums = loadedAlbums

                self.isLoadedCategories = true
                self.isLoadedCompleteGenre = true
                self.isLoadedCompleteArtist = true
                self.isLoadedCompleteAlbum = true
                self.populateIsLoaded()
            }
        } catch {
            print("Error loading data: \(error)")
            await MainActor.run {
                self.isCurrentlyLoading = false
            }
        }
    }

    private func loadAsync<T: Decodable>(_ type: T.Type, filename: String) async throws -> [T] {
        let fileURL = try fileURL(filename: filename)
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .background).async {
                do {
                    guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                        continuation.resume(returning: [])
                        return
                    }
                    let data = file.availableData
                    let returnValues = try JSONDecoder().decode([T].self, from: data)
                    continuation.resume(returning: returnValues)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func save() {
        if (isTestMode == true) {
            return;
        }
        
        save(
            IdentifiableString.self,
            filename: "excluded-genres", itemsToSave: excludedGenres) { result in
            if case .failure(let error) = result {
                fatalError(error.localizedDescription)
            }
        }
        
        save(
            IdentifiableString.self,
            filename: "excluded-artists", itemsToSave: excludedArtists) { result in
            if case .failure(let error) = result {
                fatalError(error.localizedDescription)
            }
        }
        
        save(
            IdentifiableString.self,
            filename: "excluded-albums", itemsToSave: excludedAlbums) { result in
            if case .failure(let error) = result {
                fatalError(error.localizedDescription)
            }
        }
        
        save(
            Category.self,
            filename: "categories", itemsToSave: categories) { result in
            if case .failure(let error) = result {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    private static let iCloudContainerIdentifier = "iCloud.com.benday.Playlists"

    private func localFileURL(filename: String) throws -> URL {
        return try FileManager.default.url(for: .documentDirectory,
                                           in: .userDomainMask,
                                           appropriateFor: nil,
                                           create: false)
            .appendingPathComponent("\(filename).data")
    }

    private func iCloudFileURL(filename: String) throws -> URL? {
        guard let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: Self.iCloudContainerIdentifier) else {
            return nil
        }
        let documentsURL = iCloudURL.appendingPathComponent("Documents")

        // Ensure the Documents folder exists in iCloud container
        if !FileManager.default.fileExists(atPath: documentsURL.path) {
            try FileManager.default.createDirectory(at: documentsURL, withIntermediateDirectories: true)
        }

        return documentsURL.appendingPathComponent("\(filename).data")
    }

    private func migrateLocalDataToICloudIfNeeded() async {
        // Skip if already migrated
        guard !UserDefaults.standard.bool(forKey: Self.migrationKey) else {
            print("iCloud migration: Already completed, skipping")
            return
        }

        // Skip if iCloud is not available
        guard FileManager.default.url(forUbiquityContainerIdentifier: Self.iCloudContainerIdentifier) != nil else {
            print("iCloud migration: iCloud not available, skipping")
            return
        }

        print("iCloud migration: Starting migration of local data to iCloud...")

        var migratedCount = 0
        for filename in Self.dataFilenames {
            do {
                let localURL = try localFileURL(filename: filename)
                guard let iCloudURL = try iCloudFileURL(filename: filename) else { continue }

                // Check if local file exists
                guard FileManager.default.fileExists(atPath: localURL.path) else {
                    print("iCloud migration: No local file for \(filename), skipping")
                    continue
                }

                // Check if iCloud file already exists (don't overwrite)
                if FileManager.default.fileExists(atPath: iCloudURL.path) {
                    print("iCloud migration: iCloud file already exists for \(filename), skipping")
                    continue
                }

                // Copy local file to iCloud
                try FileManager.default.copyItem(at: localURL, to: iCloudURL)
                print("iCloud migration: Successfully migrated \(filename)")
                migratedCount += 1
            } catch {
                print("iCloud migration: Error migrating \(filename): \(error)")
            }
        }

        // Mark migration as complete
        UserDefaults.standard.set(true, forKey: Self.migrationKey)
        print("iCloud migration: Complete. Migrated \(migratedCount) files.")
    }

    private func fileURL(filename: String) throws -> URL {
        // Try iCloud first
        if let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: Self.iCloudContainerIdentifier) {
            let documentsURL = iCloudURL.appendingPathComponent("Documents")

            // Ensure the Documents folder exists in iCloud container
            if !FileManager.default.fileExists(atPath: documentsURL.path) {
                try FileManager.default.createDirectory(at: documentsURL, withIntermediateDirectories: true)
            }

            print("Using iCloud storage: \(documentsURL.path)")
            return documentsURL.appendingPathComponent("\(filename).data")
        }

        // Fallback to local Documents directory if iCloud unavailable
        print("iCloud unavailable, using local storage")
        return try FileManager.default.url(for: .documentDirectory,
                                           in: .userDomainMask,
                                           appropriateFor: nil,
                                           create: false)
            .appendingPathComponent("\(filename).data")
    }
    
    private func load<T>(
        _ type: T.Type,
        filename: String, completion: @escaping (Result<[T], Error>)->Void) where T : Decodable {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try self.fileURL(filename: filename)
                
                print("Loading \(filename) from \(fileURL.absoluteString)...")
                
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        // For arrays, return empty array; for other types this would need adjustment
                        if let emptyArray = [] as? [T] {
                            completion(.success(emptyArray))
                        } else {
                            completion(.failure(NSError(domain: "FileNotFound", code: 404, userInfo: nil)))
                        }
                    }
                    return
                }
                
                let data = file.availableData
                                
                let returnValues = try JSONDecoder().decode([T].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(returnValues))
                }
            } catch (let error) {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func save<T: Encodable>(
        _ type: T.Type,
        filename: String,
        itemsToSave: [T],
        completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            do {
                let data = try JSONEncoder().encode(itemsToSave)
                let outfile = try self.fileURL(filename: filename)
                try data.write(to: outfile)
                DispatchQueue.main.async {
                    completion(.success(itemsToSave.count))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
