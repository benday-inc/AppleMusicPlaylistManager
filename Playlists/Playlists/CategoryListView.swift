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
        NavigationView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Filter Categories")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.leading)
                HStack {
                    TextField("Type to filter...", text: $viewModel.filterTextValue)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .onSubmit {
                            viewModel.updateFilteredItems()
                        }
                    if viewModel.isFiltered {
                        Button(action: {
                            viewModel.filterTextValue = ""
                            viewModel.updateFilteredItems()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .padding(.trailing)
                    }
                }
                List(selection: $viewModel.selectedItem) {
                    ForEach(viewModel.items) { item in
                        VStack{
                            Text(item.name)
                            HStack {
                                Text("Artists: \(item.artists.count) Genres: \(item.genres.count)")
                                    .font(.caption)
                            }
                        }
                        .tag(item)
                    }                
                }
            }
            .navigationTitle("Category List")
            .toolbar(content: {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Add") {
                        _ = viewModel.addNewCategory()
                    }
                    .disabled(viewModel.isLoaded == false)
                    Button("Remove") {
                        viewModel.removeCategory()
                    }
                    .disabled(viewModel.selectedItem == nil || viewModel.isLoaded == false)
                }
            })
        }
        .navigationViewStyle(.stack)
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
