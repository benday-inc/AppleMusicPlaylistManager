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
    
    func testLoadFromEmptyCategoryNamePopulateName() throws {
        // arrange
        var category = getEmptyCategory()
        
        let sut = CategoryViewModel()
        
        // act
        sut.load(category)
        
        // assert
        XCTAssertTrue(sut.isLoaded)
        XCTAssertFalse(sut.hasChanges)
        XCTAssertEqual("New Category", sut.name)
        XCTAssertTrue(sut.genres.isEmpty)
        XCTAssertTrue(sut.artists.isEmpty)
    }
    
    func getEmptyCategory() -> Playlists.Category {
        var category = Category()
        
        category.artists = []
        category.genres = []
        category.name = ""
        
        return category
    }
    
    func getPopulatedCategory() -> Playlists.Category {
        var category = Category()
        
        category.artists = ["artist1", "artist2", "artist3"]
        category.genres = ["genre1", "genre2"]
        category.name = "Test Category"
        
        return category
    }
    
    func testLoadFromPopulatedCategory() throws {
        // arrange
        var category = getPopulatedCategory()
        
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
    
    func testSetName_HasChangesIsTrue() throws {
        // arrange
        let category = getPopulatedCategory()
        
        let sut = CategoryViewModel()
        
        sut.load(category)
        
        // act
        sut.name = "New Name"
        
        // assert
        XCTAssertTrue(sut.isLoaded)
        XCTAssertTrue(sut.hasChanges)
        XCTAssertEqual("New Name", sut.name)
        XCTAssertFalse(sut.genres.isEmpty)
        XCTAssertFalse(sut.artists.isEmpty)
        XCTAssertEqual(sut.genres, ["genre1", "genre2"])
        XCTAssertEqual(sut.artists, ["artist1", "artist2", "artist3"])
    }
    
    func testRemoveGenre_HasChangesIsTrue() throws {
        // arrange
        let category = getPopulatedCategory()
        
        let sut = CategoryViewModel()
        
        sut.load(category)
        
        // act
        sut.genres.remove(at: 0)
        
        // assert
        XCTAssertTrue(sut.isLoaded)
        XCTAssertTrue(sut.hasChanges)
        XCTAssertFalse(sut.genres.isEmpty)
        XCTAssertFalse(sut.artists.isEmpty)
        XCTAssertEqual(sut.genres, ["genre2"])
        XCTAssertEqual(sut.artists, ["artist1", "artist2", "artist3"])
    }
    
    func testAddGenre_HasChangesIsTrue() throws {
        // arrange
        let category = getPopulatedCategory()
        
        let sut = CategoryViewModel()
        
        sut.load(category)
        
        // act
        sut.genres.append("genre3")
        
        // assert
        XCTAssertTrue(sut.isLoaded)
        XCTAssertTrue(sut.hasChanges)
        XCTAssertFalse(sut.genres.isEmpty)
        XCTAssertFalse(sut.artists.isEmpty)
        XCTAssertEqual(sut.genres, ["genre1", "genre2", "genre3"])
        XCTAssertEqual(sut.artists, ["artist1", "artist2", "artist3"])
    }
    
    func testModifyGenre_HasChangesIsTrue() throws {
        // arrange
        let category = getPopulatedCategory()
        
        let sut = CategoryViewModel()
        
        sut.load(category)
        
        // act
        sut.genres[0] = "genre123"
        
        // assert
        XCTAssertTrue(sut.isLoaded)
        XCTAssertTrue(sut.hasChanges)
        XCTAssertFalse(sut.genres.isEmpty)
        XCTAssertFalse(sut.artists.isEmpty)
        XCTAssertEqual(sut.genres, ["genre123", "genre2"])
        XCTAssertEqual(sut.artists, ["artist1", "artist2", "artist3"])
    }
    
    func testRemoveArtist_HasChangesIsTrue() throws {
        // arrange
        let category = getPopulatedCategory()
        
        let sut = CategoryViewModel()
        
        sut.load(category)
        
        // act
        sut.artists.remove(at: 0)
        
        // assert
        XCTAssertTrue(sut.isLoaded)
        XCTAssertTrue(sut.hasChanges)
        XCTAssertFalse(sut.genres.isEmpty)
        XCTAssertFalse(sut.artists.isEmpty)
        XCTAssertEqual(sut.genres, ["genre1", "genre2"])
        XCTAssertEqual(sut.artists, ["artist2", "artist3"])
    }
    
    func testAddArtist_HasChangesIsTrue() throws {
        // arrange
        let category = getPopulatedCategory()
        
        let sut = CategoryViewModel()
        
        sut.load(category)
        
        // act
        sut.artists.append("artist4")
        
        // assert
        XCTAssertTrue(sut.isLoaded)
        XCTAssertTrue(sut.hasChanges)
        XCTAssertFalse(sut.genres.isEmpty)
        XCTAssertFalse(sut.artists.isEmpty)
        XCTAssertEqual(sut.genres, ["genre1", "genre2"])
        XCTAssertEqual(sut.artists, ["artist1", "artist2", "artist3", "artist4"])
    }
    
    func testModifyArtist_HasChangesIsTrue() throws {
        // arrange
        let category = getPopulatedCategory()
        
        let sut = CategoryViewModel()
        
        sut.load(category)
        
        // act
        sut.artists[0] = "artist123"
        
        // assert
        XCTAssertTrue(sut.isLoaded)
        XCTAssertTrue(sut.hasChanges)
        XCTAssertFalse(sut.genres.isEmpty)
        XCTAssertFalse(sut.artists.isEmpty)
        XCTAssertEqual(sut.genres, ["genre1", "genre2"])
        XCTAssertEqual(sut.artists, ["artist123", "artist2", "artist3"])
    }
    
    func testUndoChanges_RevertsValuesAndHasChangesIsFalse() throws {
        // arrange
        let category = getPopulatedCategory()
        
        let sut = CategoryViewModel()
        
        sut.load(category)
        sut.name = "New Name"
        sut.artists[0] = "artist123"
        sut.genres.remove(at: 0)
        XCTAssertTrue(sut.hasChanges)
        
        // act
        sut.undoChanges()
        
        // assert
        XCTAssertTrue(sut.isLoaded)
        XCTAssertFalse(sut.hasChanges)
        XCTAssertEqual("Test Category", sut.name)
        XCTAssertFalse(sut.genres.isEmpty)
        XCTAssertFalse(sut.artists.isEmpty)
        XCTAssertEqual(sut.genres, ["genre1", "genre2"])
        XCTAssertEqual(sut.artists, ["artist1", "artist2", "artist3"])
    }
    
    func testSaveChanges_UpdatesModelAndHasChangesIsFalse() throws {
        // arrange
        let category = getPopulatedCategory()
        
        let sut = CategoryViewModel()
        
        sut.load(category)
        sut.name = "New Name"
        sut.artists[0] = "artist123"
        sut.genres.remove(at: 0)
        XCTAssertTrue(sut.hasChanges)
        
        // act
        let updatedModel = sut.saveChanges()
        
        // assert
        XCTAssertTrue(sut.isLoaded)
        XCTAssertFalse(sut.hasChanges)
        XCTAssertEqual("New Name", sut.name)
        XCTAssertFalse(sut.genres.isEmpty)
        XCTAssertFalse(sut.artists.isEmpty)
        XCTAssertEqual(sut.genres, ["genre2"])
        XCTAssertEqual(sut.artists, ["artist123", "artist2", "artist3"])
        
        XCTAssertEqual(updatedModel.name, "New Name")
        XCTAssertEqual(updatedModel.genres, ["genre2"])
        XCTAssertEqual(updatedModel.artists, ["artist123", "artist2", "artist3"])
        
        XCTAssertEqual(updatedModel.id, category.id) // id should be unchanged
        
    }

}
