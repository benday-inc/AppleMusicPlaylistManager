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
            VStack {
                HStack {
                    if (viewModel.isLoaded == true) {
                        Text("Filter")
                        Spacer()
                            
                        TextField("Filter", text: $viewModel.filterTextValue)
                            .frame(width: 150)
                            .onSubmit {
                                viewModel.updateFilteredItems()
                            }
                        if (viewModel.isFiltered == true) {
                            Button("Clear") {
                                viewModel.filterTextValue = ""
                                viewModel.updateFilteredItems()
                            }
                        }
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
