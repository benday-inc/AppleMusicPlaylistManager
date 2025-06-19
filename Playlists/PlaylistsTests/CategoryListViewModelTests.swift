//
//  CategoryListViewModelTests.swift
//  PlaylistsTests
//
//  Created by Benjamin Day on 6/19/25.
//

import XCTest
@testable import Playlists

final class CategoryListViewModelTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func getListOfCategories() -> [Playlists.Category] {
        var categories: [Playlists.Category] = []
        
        var category1 = Playlists.Category()
        category1.name = "Category 1"
        category1.genres = ["Genre A", "Genre B"]
        category1.artists = ["Artist X", "Artist Y"]
        
        var category2 = Playlists.Category()
        category2.name = "Category 2"
        category2.genres = ["Genre C"]
        category2.artists = ["Artist Z"]
        
        categories.append(category1)
        categories.append(category2)
        
        return categories
    }
    
    func testVerifyAfterInit() throws {
        let sut = CategoryListViewModel()
        
        XCTAssertFalse(sut.isLoaded)
        XCTAssertFalse(sut.isFiltered)
        XCTAssertTrue(sut.items.isEmpty)
        XCTAssertTrue(sut.unfilteredItems.isEmpty)
        XCTAssertNil(sut.selectedItem)
        XCTAssertEqual("", sut.filterTextValue)
        XCTAssertFalse(sut.hasChanges)
    }
    
    func testAddNewCategory() throws {
        let sut = CategoryListViewModel()
        
        sut.addNewCategory()
        
        XCTAssertFalse(sut.isLoaded)
        XCTAssertFalse(sut.isFiltered)
        XCTAssertFalse(sut.items.isEmpty)
        XCTAssertFalse(sut.unfilteredItems.isEmpty)
        XCTAssertNotNil(sut.selectedItem)
        XCTAssertEqual("", sut.filterTextValue)
        XCTAssertTrue(sut.hasChanges)
        
        let selected = sut.selectedItem!
        
        XCTAssertEqual("New Category", selected.name)
    }
    
    func testAddNewCategoryMultipleTimes() throws {
        let sut = CategoryListViewModel()
        
        sut.addNewCategory()
        
        XCTAssertNotNil(sut.selectedItem)
        var selected = sut.selectedItem!
        XCTAssertEqual("New Category", selected.name)
        
        sut.addNewCategory()
        
        XCTAssertNotNil(sut.selectedItem)
        selected = sut.selectedItem!
        XCTAssertEqual("New Category 1", selected.name)
        
        sut.addNewCategory()
        
        XCTAssertNotNil(sut.selectedItem)
        selected = sut.selectedItem!
        XCTAssertEqual("New Category 2", selected.name)
        
        XCTAssertTrue(sut.hasChanges)
    }

    func testLoadFromList() throws {
        let sut = CategoryListViewModel()
        
        let categories = getListOfCategories()
        
        sut.load(from: categories)
        
        XCTAssertFalse(sut.hasChanges)
        XCTAssertTrue(sut.isLoaded)
        XCTAssertFalse(sut.isFiltered)
        XCTAssertEqual(2, sut.items.count)
        XCTAssertEqual(2, sut.unfilteredItems.count)
        XCTAssertNil(sut.selectedItem)
        XCTAssertEqual("", sut.filterTextValue)
        XCTAssertEqual("Category 1", sut.items[0].name)
        XCTAssertEqual("Category 2", sut.items[1].name)
        XCTAssertEqual("Category 1", sut.unfilteredItems[0].name)
        XCTAssertEqual("Category 2", sut.unfilteredItems[1].name)
    }

}


