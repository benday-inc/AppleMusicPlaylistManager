//
//  PlaylistDataStoreTests.swift
//  Random Playlist Generator
//
//  Created by Benjamin Day on 4/10/25.
//


import XCTest

@testable import Random_Playlist_Generator

final class PlaylistDataStoreTests : XCTestCase {

    func testCreateInstanceWithEmptyExclusions() async throws {
        // Write your test here and use APIs like `XCTAssert(...)` to check expected conditions.
        
        let sut = PlaylistDataStore(testDataExcludedGenres: [],
                                    testDataExcludedArtists: [],
                                    testDataExcludedAlbums: [])
        
        XCTAssertTrue(sut.excludedAlbums.isEmpty)
        
        XCTAssertTrue(sut.excludedArtists.isEmpty)
        
        XCTAssertTrue(sut.excludedGenres.isEmpty)
    }
    
    func testInAllSongsModeEmptyExclusionsShouldNotExclude() async throws {
        // Write your test here and use APIs like `XCTAssert(...)` to check expected conditions.
        
        let sut = PlaylistDataStore(testDataExcludedGenres: [],
                                    testDataExcludedArtists: [],
                                    testDataExcludedAlbums: [])
        
        let sampleItemMediaItemWrapper = MediaItemWrapper(
            trackName: "track name",
            albumName: "album name",
            artistName: "artist name",
            genreName: "genre name")
        
        let expected = false
        
        let actual = sut.isExcluded(item: sampleItemMediaItemWrapper, playlistMode: AppConstants.PLAYLIST_MODE_ALL)
        
        XCTAssertEqual(expected, actual)
    }
    
    func testInAllSongsMode_Exclude_ExcludedGenre() async throws {
        // Write your test here and use APIs like `XCTAssert(...)` to check expected conditions.
        
        let excluded: String = "ExcludedGenre"
        let excludedIdentifiableString = IdentifiableString(value: excluded)
        
        let sut = PlaylistDataStore(testDataExcludedGenres: [excludedIdentifiableString],
                                    testDataExcludedArtists: [],
                                    testDataExcludedAlbums: [])
        
        let sampleItemMediaItemWrapper = MediaItemWrapper(
            trackName: "track name",
            albumName: "album name",
            artistName: "artist name",
            genreName: excluded)
        
        let expected = true
        
        let actual = sut.isExcluded(item: sampleItemMediaItemWrapper, playlistMode: AppConstants.PLAYLIST_MODE_ALL)
        
        XCTAssertEqual(expected, actual)
    }
    
    func testInAllSongsMode_DontExclude_NonExcludedGenre() async throws {
        // Write your test here and use APIs like `XCTAssert(...)` to check expected conditions.
        
        let excluded: String = "ExcludedGenre"
        let excludedIdentifiableString = IdentifiableString(value: excluded)
        
        let sut = PlaylistDataStore(testDataExcludedGenres: [excludedIdentifiableString],
                                    testDataExcludedArtists: [],
                                    testDataExcludedAlbums: [])
        
        let sampleItemMediaItemWrapper = MediaItemWrapper(
            trackName: "track name",
            albumName: "album name",
            artistName: "artist name",
            genreName: "genre name")
        
        let expected = false
        
        let actual = sut.isExcluded(item: sampleItemMediaItemWrapper, playlistMode: AppConstants.PLAYLIST_MODE_ALL)
        
        XCTAssertEqual(expected, actual)
    }
    
   

}
