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
    private var model: [Category]?
    
    public init() {
        
    }
    
    // declare a property to get hasChanges
    public var hasChanges: Bool {
        return items.contains(where: { $0.hasChanges })
    }
    
    public func load(from categories: [Category]) {
        isLoaded = false
        items = categories.map { category in
            let viewModel = CategoryViewModel()
            viewModel.load(category)
            return viewModel
        }
        unfilteredItems = items
        isLoaded = true
    }
    
    public func addNewCategory() -> CategoryViewModel {
        print("Add New Category")
        let newCategory = CategoryViewModel()
        newCategory.name = getNewCategoryName()
        unfilteredItems.append(newCategory)
        selectedItem = newCategory
        
        updateFilteredItems()
        
        return newCategory
    }
    
    public func removeCategory() {
        if selectedItem == nil {
            return
        }
        
        if let tempSelectedItem = selectedItem,
           let selectedIndex = unfilteredItems.firstIndex(where: { $0.id == tempSelectedItem.id }) {
            unfilteredItems.remove(at: selectedIndex)
            selectedItem = nil
            updateFilteredItems()
        }
    }
    
    private func getNewCategoryName() -> String {
        let baseName = "New Category"
        var uniquifier = 0
        var uniqueName = baseName
        
        // while contains baseName, increment number
        
        while unfilteredItems.contains(where: { $0.name == uniqueName }) {
            uniquifier += 1
            uniqueName = "\(baseName) \(uniquifier)"
        }
        
        return uniqueName
    }
    
    public func updateFilteredItems() {
        if filterTextValue.isEmpty {
            isFiltered = false
            items = unfilteredItems
        }
        else {
            isFiltered = true
            let lowerFilter = filterTextValue.lowercased()
            items = unfilteredItems.filter { categoryVM in
                categoryVM.name.lowercased().contains(lowerFilter)
            }
        }
    }
    
    public func toModels() -> [Category] {
        
        var returnValues = [Category]()
        
        for item in items {
            let toItem = item.saveChanges()
            
            returnValues.append(toItem)
        }
        
        return returnValues
    }
}




