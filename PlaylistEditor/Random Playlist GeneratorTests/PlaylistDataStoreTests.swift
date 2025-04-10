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
    
    func testCreateInstanceWithNotEmptyAlbumExclusions() async throws {
        let excluded: String = "EXCLUDED"
        let excludedIdentifiableString = IdentifiableString(value: excluded)
        
        let sut = PlaylistDataStore(testDataExcludedGenres: [],
                                    testDataExcludedArtists: [],
                                    testDataExcludedAlbums: [excludedIdentifiableString])
        
        XCTAssertTrue(!sut.excludedAlbums.isEmpty)
        XCTAssertTrue(sut.excludedArtists.isEmpty)
        XCTAssertTrue(sut.excludedGenres.isEmpty)
    }
    
    func testCreateInstanceWithNotEmptyArtistExclusions() async throws {
        let excluded: String = "EXCLUDED"
        let excludedIdentifiableString = IdentifiableString(value: excluded)
        
        let sut = PlaylistDataStore(testDataExcludedGenres: [],
                                    testDataExcludedArtists: [excludedIdentifiableString],
                                    testDataExcludedAlbums: [])
        
        XCTAssertTrue(sut.excludedAlbums.isEmpty)
        XCTAssertTrue(!sut.excludedArtists.isEmpty)
        XCTAssertTrue(sut.excludedGenres.isEmpty)
    }
    
    func testCreateInstanceWithNotEmptyGenreExclusions() async throws {
        let excluded: String = "EXCLUDED"
        let excludedIdentifiableString = IdentifiableString(value: excluded)
        
        let sut = PlaylistDataStore(testDataExcludedGenres: [excludedIdentifiableString],
                                    testDataExcludedArtists: [],
                                    testDataExcludedAlbums: [])
        
        XCTAssertTrue(sut.excludedAlbums.isEmpty)
        XCTAssertTrue(sut.excludedArtists.isEmpty)
        XCTAssertTrue(!sut.excludedGenres.isEmpty)
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
        
        let excluded: String = "EXCLUDED"
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
        
        let excluded: String = "EXCLUDED"
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
    
    func testInAllSongsMode_Exclude_ExcludedArtist() async throws {
        // Write your test here and use APIs like `XCTAssert(...)` to check expected conditions.
        
        let excluded: String = "EXCLUDED"
        let excludedIdentifiableString = IdentifiableString(value: excluded)
        
        let sut = PlaylistDataStore(testDataExcludedGenres: [],
                                    testDataExcludedArtists: [excludedIdentifiableString],
                                    testDataExcludedAlbums: [])
        
        let sampleItemMediaItemWrapper = MediaItemWrapper(
            trackName: "track name",
            albumName: "album name",
            artistName: excluded,
            genreName: "genre")
        
        let expected = true
        
        let actual = sut.isExcluded(item: sampleItemMediaItemWrapper, playlistMode: AppConstants.PLAYLIST_MODE_ALL)
        
        XCTAssertEqual(expected, actual)
    }
    
    func testInAllSongsMode_DontExclude_NonExcludedArtist() async throws {
        // Write your test here and use APIs like `XCTAssert(...)` to check expected conditions.
        
        let excluded: String = "EXCLUDED"
        let excludedIdentifiableString = IdentifiableString(value: excluded)
        
        let sut = PlaylistDataStore(testDataExcludedGenres: [],
                                    testDataExcludedArtists: [excludedIdentifiableString],
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
    
    func testInAllSongsMode_Exclude_ExcludedAlbum() async throws {
        // Write your test here and use APIs like `XCTAssert(...)` to check expected conditions.
        
        let excluded: String = "artist name - EXCLUDED"
        let excludedIdentifiableString = IdentifiableString(value: excluded)
        
        let sut = PlaylistDataStore(testDataExcludedGenres: [],
                                    testDataExcludedArtists: [],
                                    testDataExcludedAlbums: [excludedIdentifiableString])
        
        let sampleItemMediaItemWrapper = MediaItemWrapper(
            trackName: "track name",
            albumName: excluded,
            artistName: "artist name",
            genreName: "genre")
        
        let expected = true
        
        let actual = sut.isExcluded(item: sampleItemMediaItemWrapper, playlistMode: AppConstants.PLAYLIST_MODE_ALL)
        
        XCTAssertEqual(expected, actual)
    }
    
    func testInAllSongsMode_DontExclude_NonExcludedAlbum() async throws {
        // Write your test here and use APIs like `XCTAssert(...)` to check expected conditions.
        
        let excluded: String = "EXCLUDED"
        let excludedIdentifiableString = IdentifiableString(value: excluded)
        
        let sut = PlaylistDataStore(testDataExcludedGenres: [],
                                    testDataExcludedArtists: [],
                                    testDataExcludedAlbums: [excludedIdentifiableString])
        
        let sampleItemMediaItemWrapper = MediaItemWrapper(
            trackName: "track name",
            albumName: "album name",
            artistName: "artist name",
            genreName: "genre name")
        
        let expected = false
        
        let actual = sut.isExcluded(item: sampleItemMediaItemWrapper, playlistMode: AppConstants.PLAYLIST_MODE_ALL)
        
        XCTAssertEqual(expected, actual)
    }
    
   
    func testCreateMediaItemWrapperPopulatesProperties() async throws {
        // Write your test here and use APIs like `XCTAssert(...)` to check expected conditions.
        
        let expectedTrackName: String = "track name"
        let expectedAlbumName: String = "album name"
        let expectedArtistName: String = "artist name"
        let expectedGenreName: String = "genre name"
                
        let actual = MediaItemWrapper(
            trackName: expectedTrackName,
            albumName: expectedAlbumName,
            artistName: expectedArtistName,
            genreName: expectedGenreName)
        
        XCTAssertEqual(expectedTrackName, actual.trackName, "track name")
        XCTAssertEqual(expectedAlbumName, actual.albumName, "album name")
        XCTAssertEqual(expectedArtistName, actual.artistName, "artist name")
        XCTAssertEqual(expectedGenreName, actual.genreName, "genre name")
    }
}
