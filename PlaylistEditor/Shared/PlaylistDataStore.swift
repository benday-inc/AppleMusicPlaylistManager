//
//  PlaylistDataStore.swift
//  PlaylistEditor (iOS)
//
//  Created by Benjamin Day on 12/27/21.
//


import Foundation
import SwiftUI

class PlaylistDataStore: ObservableObject {
    @Published var excludedGenres: [IdentifiableString] = []
    @Published var excludedArtists: [IdentifiableString] = []
    @Published var excludedAlbums: [IdentifiableString] = []
    @Published var excludedTracks: [IdentifiableString] = []
    
    init() {
    
    }
    
    init(testData: [IdentifiableString]) {
        excludedGenres = testData
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
    
    func load() {
        PlaylistDataStore.load { result in
            switch result {
            case .failure(let error):
                fatalError(error.localizedDescription)
            case .success(let temp):
                self.excludedGenres = temp
            }
        }
    }
    
    func save() {
        PlaylistDataStore.save(itemsToSave: excludedGenres) { result in
            if case .failure(let error) = result {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                       in: .userDomainMask,
                                       appropriateFor: nil,
                                       create: false)
            .appendingPathComponent("excluded-genres.data")
    }
    
    private static func load(completion: @escaping (Result<[IdentifiableString], Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL()
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
    
    private static func save(itemsToSave: [IdentifiableString], completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(itemsToSave)
                let outfile = try fileURL()
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
