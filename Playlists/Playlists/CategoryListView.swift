//
//  CategoryListView.swift
//  Playlists
//
//  Created by Benjamin Day on 6/19/25.
//

import SwiftUI

struct CategoryListView: View {
    @EnvironmentObject var viewModel: CategoryListViewModel
    
    @State private var isNavigating = false
    
    var body: some View {
        NavigationStack {
            VStack {
                List(viewModel.items) { item in
                    Button(
                        action: {
                            viewModel.selectedItem = item
                            isNavigating = true
                        },
                        label: {
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                Text("Artists: \(item.artists.count) Genres: \(item.genres.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    )
                    .buttonStyle(PlainButtonStyle())                    
                }
                
                .navigationDestination(isPresented: $isNavigating) {
                    if let selected = viewModel.selectedItem {
                        CategoryEditorView(category: selected, viewModel: viewModel)
                    } else {
                        Text("Nothing selected")
                    }
                }
            }
            .searchable(text: $viewModel.filterTextValue, prompt: "Filter categories")
            .onChange(of: viewModel.filterTextValue) {
                viewModel.updateFilteredItems()
            }
            .navigationTitle("Category List")
            .toolbar {
                Button("Add") { _ = viewModel.addNewCategory() }
                    .disabled(!viewModel.isLoaded)
            }
            
            
            
        }
    }
    
    
    
}

#Preview("with items") {
    let viewModel = CategoryListViewModel()
    let categories = CategoryUtilities.getPopulatedCategories(numberOfItems: 5)
    viewModel.load(from: categories)
    return CategoryListView().environmentObject(viewModel)
}

#Preview("no items") {
    let viewModel = CategoryListViewModel()
    return CategoryListView().environmentObject(viewModel)
}
