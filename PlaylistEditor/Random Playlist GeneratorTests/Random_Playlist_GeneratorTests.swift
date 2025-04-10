//
//  Random_Playlist_GeneratorTests.swift
//  Random Playlist GeneratorTests
//
//  Created by Benjamin Day on 4/10/25.
//

import Testing
@testable import Random_Playlist_Generator

struct PlaylistDataStoreTests {

    @Test func createInstance() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        
        let sut = PlaylistDataStore(testDataExcludedGenres: [],
                                    testDataExcludedArtists: [],
                                    testDataExcludedAlbums: [])
        
        #expect(sut.excludedAlbums.isEmpty)
        
        #expect(sut.excludedArtists.isEmpty)
        
        #expect(sut.excludedGenres.isEmpty)
    }

}
