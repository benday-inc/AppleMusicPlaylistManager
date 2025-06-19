//
//  CategoryViewModel.swift
//  Playlists
//
//  Created by Benjamin Day on 6/19/25.
//


import Foundation
import Combine

public class CategoryViewModel : ObservableObject {
    @Published var isLoaded: Bool = false
    @Published var hasChanges: Bool = false
    @Published var name: String {
        didSet {
            if let model = model {
                hasChanges = (name != model.name)
            }
            else {
                hasChanges = true
            }
        }
    }
    @Published var genres: [String] = [] {
        didSet {
            if let model = model {
                hasChanges = (genres != model.genres)
            }
            else {
                hasChanges = true
            }
        }
    }
    
    @Published var artists: [String] = [] {
        didSet {
            if let model = model {
                hasChanges = (artists != model.artists)
            }
            else {
                hasChanges = true
            }
        }
    }
    
    private var model: Category?
    
    init() {
        self.name = ""
    }
    
    public func load(_ fromValue: Category) {
        isLoaded = false
        
        model = fromValue
        name = fromValue.name
        
        if (name.isEmpty == true) {
            name = "New Category"
        }
        
        genres = fromValue.genres
        artists = fromValue.artists
        
        isLoaded = true
    }
}
