//
//  CategoryViewModel.swift
//  Playlists
//
//  Created by Benjamin Day on 6/19/25.
//


import Foundation
import Combine

public class CategoryViewModel : ObservableObject, Identifiable {
    @Published public var id: UUID = UUID()
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
    
    public func undoChanges() {
        if let model = model {
            load(model)
        }
    }
    
    public func load(_ fromValue: Category) {
        isLoaded = false
        
        id = fromValue.id
        model = fromValue
        name = fromValue.name
        
        if (name.isEmpty == true) {
            name = "New Category"
        }
        
        genres = fromValue.genres
        artists = fromValue.artists
        
        isLoaded = true
    }
    
    public func saveChanges() -> Category {
        var updatedModel = Category()
        
        updatedModel.id = model?.id ?? UUID()
        updatedModel.name = name
        updatedModel.genres = genres
        updatedModel.artists = artists
        
        model = updatedModel
        hasChanges = false
        
        return updatedModel
    }
}
