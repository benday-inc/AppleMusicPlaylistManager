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
    
    init() {
    
    }
    
    init(testData: [IdentifiableString]) {
        excludedGenres = testData
    }
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                       in: .userDomainMask,
                                       appropriateFor: nil,
                                       create: false)
            .appendingPathComponent("excluded-genres.data")
    }
    
    static func load(completion: @escaping (Result<[String], Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }
                let returnValues = try JSONDecoder().decode([String].self, from: file.availableData)
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
    
    static func save(itemsToSave: [String], completion: @escaping (Result<Int, Error>)->Void) {
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
