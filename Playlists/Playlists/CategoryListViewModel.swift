//
//  CategoryListViewModel.swift
//  Playlists
//
//  Created by Benjamin Day on 6/19/25.
//

import Foundation
import Combine

public class CategoryListViewModel : ObservableObject {
    @Published var isLoaded = false;
    @Published var items: [CategoryViewModel] = []
    @Published var unfilteredItems: [CategoryViewModel] = []
    @Published var selectedItem: CategoryViewModel?
    var anyCancellable: AnyCancellable? = nil
    @Published var isFiltered: Bool = false
    @Published var filterTextValue: String = ""
    
    public init() {
        
    }
    
    
}




