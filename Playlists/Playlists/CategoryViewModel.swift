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
    @Published var name: String
    @Published var genres: [String] = []
    @Published var artists: [String] = []
    private var model: Category?
    
    init() {
        self.name = ""
    }
    
    public func load(_ fromValue: Category) {
        isLoaded = false
        
        model = fromValue
        name = fromValue.name
        genres = fromValue.genres
        artists = fromValue.artists
        
        isLoaded = true
    }
}
