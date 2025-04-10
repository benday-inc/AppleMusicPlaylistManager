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
    @Published var isLoaded: Bool = false
    private var isTestMode: Bool = false
    private var isLoadedCompleteGenre: Bool = false
    private var isLoadedCompleteArtist: Bool = false
    private var isLoadedCompleteAlbum: Bool = false
    
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
        let searchForValueAsIdentifiableString = IdentifiableString(value: searchForValue)
        
        let result = searchInValues.firstIndex(of: searchForValueAsIdentifiableString)
        
        if (result != nil) {
            print("Found '\(searchForValue)' '\(searchInValues.count)' items")
            return true
        }
        else {
            print("Did not find '\(searchForValue)' '\(searchInValues.count)' items")
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
        
        PlaylistDataStore.load(filename: "excluded-genres") { result in
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
        
        PlaylistDataStore.load(filename: "excluded-artists") { result in
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
        
        PlaylistDataStore.load(filename: "excluded-albums") { result in
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
        
        PlaylistDataStore.save(filename: "excluded-genres", itemsToSave: excludedGenres) { result in
            if case .failure(let error) = result {
                fatalError(error.localizedDescription)
            }
        }
        
        PlaylistDataStore.save(filename: "excluded-artists", itemsToSave: excludedArtists) { result in
            if case .failure(let error) = result {
                fatalError(error.localizedDescription)
            }
        }
        
        PlaylistDataStore.save(filename: "excluded-albums", itemsToSave: excludedAlbums) { result in
            if case .failure(let error) = result {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    private static func fileURL(filename: String) throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                       in: .userDomainMask,
                                       appropriateFor: nil,
                                       create: false)
            .appendingPathComponent("\(filename).data")
    }
    
    private static func load(filename: String, completion: @escaping (Result<[IdentifiableString], Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL(filename: filename)
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }
                let returnValues = try JSONDecoder().decode([IdentifiableString].self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(returnValues))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    private static func save(filename: String, itemsToSave: [IdentifiableString], completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(itemsToSave)
                let outfile = try fileURL(filename: filename)
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
