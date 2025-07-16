//
//  PlaylistDataStore.swift
//  RandomPlaylistGenerator (iOS)
//
//  Created by Benjamin Day on 12/27/21.
//


import Foundation
import SwiftUI



class PlaylistDataStore: ObservableObject {
    @Published var excludedGenres: [IdentifiableString] = []
    @Published var excludedArtists: [IdentifiableString] = []
    @Published var excludedAlbums: [IdentifiableString] = []
    @Published var categories: [Category] = []
    @Published var isLoaded: Bool = false
    private var isTestMode: Bool = false
    private var isLoadedCompleteGenre: Bool = false
    private var isLoadedCompleteArtist: Bool = false
    private var isLoadedCompleteAlbum: Bool = false
    @Published var isLoadedCategories: Bool = false
    
    init() {
        load()
    }
    
    init(testDataExcludedGenres: [IdentifiableString],
         testDataExcludedArtists: [IdentifiableString],
         testDataExcludedAlbums: [IdentifiableString]) {
        isTestMode = true
        excludedGenres = testDataExcludedGenres
        excludedAlbums = testDataExcludedAlbums
        excludedArtists = testDataExcludedArtists
        categories = []
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
    
    func load() {
        if (isTestMode == true) {
            isLoaded = true
            return;
        }
        
        load(Category.self, filename: "categories") { result in
            switch result {
            case .failure(let error):
                print("Error loading categories: \(error)")
                fatalError(error.localizedDescription)
            case .success(let temp):
                print("Loaded categories: \(temp.count)")
                self.categories = temp
                self.isLoadedCategories = true
            }
        }

        load(IdentifiableString.self, filename: "excluded-genres") { result in
            switch result {
            case .failure(let error):
                print("Error loading excluded genres: \(error)")
                fatalError(error.localizedDescription)
            case .success(let temp):
                print("Loaded excluded genres: \(temp.count)")
                self.excludedGenres = temp
                self.isLoadedCompleteGenre = true
                
                if (self.isLoadedCompleteGenre && self.isLoadedCompleteArtist && self.isLoadedCompleteAlbum) {
                    self.isLoaded = true
                    print("all loaded")
                }
                else {
                    print("genres loaded but not all complete")
                }
            }
        }

        load(IdentifiableString.self, filename: "excluded-artists") { result in
            switch result {
            case .failure(let error):
                fatalError(error.localizedDescription)
            case .success(let temp):
                print("Loaded excluded artists: \(temp.count)")
                self.excludedArtists = temp
                self.isLoadedCompleteArtist = true
                
                if (self.isLoadedCompleteGenre && self.isLoadedCompleteArtist && self.isLoadedCompleteAlbum) {
                    self.isLoaded = true
                    print("all loaded")
                }
                else {
                    print("artists loaded but not all complete")
                }
            }
        }

        load(IdentifiableString.self, filename: "excluded-albums") { result in
            switch result {
            case .failure(let error):
                fatalError(error.localizedDescription)
            case .success(let temp):
                print("Loaded excluded albums: \(temp.count)")
                self.excludedAlbums = temp
                self.isLoadedCompleteAlbum = true
                
                if (self.isLoadedCompleteGenre && self.isLoadedCompleteArtist && self.isLoadedCompleteAlbum) {
                    self.isLoaded = true
                    print("all loaded")
                }
                else {
                    print("albums loaded but not all complete")
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
                let returnValues = try JSONDecoder().decode(T.self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(returnValues as! [T]))
                }
            } catch {
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
        DispatchQueue.global(qos: .background).async {
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
