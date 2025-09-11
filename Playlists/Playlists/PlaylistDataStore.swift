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
    
    private init() {
        // Load data asynchronously but don't create multiple concurrent load tasks
        Task { @MainActor in
            if !isLoaded {
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
    
    private func fileURL(filename: String) throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
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
