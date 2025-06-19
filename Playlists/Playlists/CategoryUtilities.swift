//
//  CategoryUtilities.swift
//  Playlists
//
//  Created by Benjamin Day on 6/19/25.
//


import Foundation
import Combine

public class CategoryUtilities {
    public static func getEmptyCategory() -> Category {
        return Category()
    }
    
    public static func getPopulatedCategories(numberOfItems: Int) -> [Category] {
        var categories: [Category] = []
        
        for i in 0..<numberOfItems {
            categories.append(getPopulatedCategory(itemNumber: i))
        }
        
        return categories
    }
    
    public static func getPopulatedCategory(itemNumber: Int) -> Category {
        var returnValue = Category()
        
        returnValue.id = UUID()
        returnValue.name = "Test Category \(itemNumber)"
        returnValue.genres = ["genre1 \(itemNumber)", "genre2 \(itemNumber)"]
        returnValue.artists = ["artist1 \(itemNumber)", "artist2 \(itemNumber)", "artist3 \(itemNumber)"]
        return returnValue
    }
}
