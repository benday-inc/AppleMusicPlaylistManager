//
//  CategoryListView.swift
//  Playlists
//
//  Created by Benjamin Day on 6/19/25.
//

import SwiftUI

struct CategoryListView: View {
    @EnvironmentObject var viewModel: CategoryListViewModel

    var body: some View {
        NavigationStack {
            List(selection: $viewModel.selectedItem) {
                ForEach(viewModel.items) { item in
                    VStack(alignment: .leading) {
                        Text(item.name)
                            .font(.headline)
                        Text("Artists: \(item.artists.count) Genres: \(item.genres.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .tag(item)
                }
            }
            .searchable(text: $viewModel.filterTextValue, prompt: "Filter categories")
            .onChange(of: viewModel.filterTextValue) { 
                viewModel.updateFilteredItems()
            }
            .navigationTitle("Category List")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Add") { _ = viewModel.addNewCategory() }
                        .disabled(!viewModel.isLoaded)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Remove") { viewModel.removeCategory() }
                        .disabled(viewModel.selectedItem == nil || !viewModel.isLoaded)
                }
            }
        }
    }
}

#Preview("with items") {
    var viewModel = CategoryListViewModel()
    let categories = CategoryUtilities.getPopulatedCategories(numberOfItems: 5)
    viewModel.load(from: categories)
    return CategoryListView().environmentObject(viewModel)
}

#Preview("no items") {
    var viewModel = CategoryListViewModel()
    return CategoryListView().environmentObject(viewModel)
}
