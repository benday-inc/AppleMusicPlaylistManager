//
//  CategoryViewModelTests.swift
//  Playlists
//
//  Created by Benjamin Day on 6/19/25.
//


import XCTest
@testable import Playlists

final class CategoryViewModelTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testVerifyAfterInit() throws {
        let sut = CategoryViewModel()
        
        XCTAssertFalse(sut.hasChanges)
        XCTAssertFalse(sut.isLoaded)
        XCTAssertEqual("", sut.name)
        XCTAssertTrue(sut.genres.isEmpty)
        XCTAssertTrue(sut.artists.isEmpty)
    }
    
    func testLoad() throws {
        // arrange
        var category = Category()
        
        category.artists = ["artist1", "artist2", "artist3"]
        category.genres = ["genre1", "genre2"]
        category.name = "Test Category"
        
        let sut = CategoryViewModel()
        
        // act
        sut.load(category)
        
        // assert
        XCTAssertTrue(sut.isLoaded)
        XCTAssertFalse(sut.hasChanges)
        XCTAssertEqual("Test Category", sut.name)
        XCTAssertFalse(sut.genres.isEmpty)
        XCTAssertFalse(sut.artists.isEmpty)
        XCTAssertEqual(sut.genres, ["genre1", "genre2"])
        XCTAssertEqual(sut.artists, ["artist1", "artist2", "artist3"])
    }
    

}
