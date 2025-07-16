//
//  CategoryListView.swift
//  Playlists
//
//  Created by Benjamin Day on 6/19/25.
//

import SwiftUI

struct CategoryListView: View {
    @StateObject var viewModel: CategoryListViewModel = CategoryListViewModel()
    @EnvironmentObject var storage: PlaylistDataStore
    @State private var categoryToPlay: Category? = nil
    @State private var isNavigating = false
    
    var body: some View {
        if (storage.isLoaded == false) {
            Text("Loading categories...")
        }
        else {
            NavigationStack {
                VStack {
                    if (viewModel.items.count == 0) {
                        VStack {
                            Text("No categories found.")
                                .font(.headline)
                            Text("Click the add button to create a new category.")
                            
                            Button("Add") {
                                _ = viewModel.addNewCategory()
                                isNavigating = true
                            }
                                .disabled(!viewModel.isLoaded)
                                .buttonStyle(.borderedProminent)
                                .font(.title3)
                                .padding()
                                .frame(minWidth: 150, minHeight: 44)

                                
                        }
                    }
                    else {
                        List(viewModel.items, selection: $viewModel.selectedItem) { item in
                            HStack()
                            {
                                Image(systemName: "music.note")
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                        .font(.headline)
                                    
                                    Text("Artists: \(item.artists.count) Genres: \(item.genres.count)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Button("Play") {
                                    let category = item.toModel()
                                    
                                    categoryToPlay = category
                                    
                                    isNavigating = true
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .onTapGesture {
                                print("ontapgesture")
                                viewModel.selectedItem = item
                                isNavigating = true
                            }
                            .swipeActions(content: {
                                Button(role: .destructive) {
                                    viewModel.selectedItem = item
                                    viewModel.removeCategory()
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            })
                            
                        }
                        .navigationDestination(isPresented: $isNavigating) {
                            if (categoryToPlay != nil) {
                                SongsView(category: categoryToPlay!, storage: storage)
                            }
                            else {
                                if let selected = viewModel.selectedItem {
                                    CategoryEditorView(category: selected, viewModel: viewModel)
                                } else {
                                    Text("Nothing selected")
                                }
                            }
                        }
                    }
                }
                .searchable(text: $viewModel.filterTextValue, prompt: "Filter categories")
                .onChange(of: viewModel.filterTextValue) {
                    viewModel.updateFilteredItems()
                }
                .navigationTitle("Category List")
                .toolbar {
                    Button("Add") {
                        _ = viewModel.addNewCategory()
                        isNavigating = true
                    }
                    .disabled(!viewModel.isLoaded)
                }
                .onAppear() {
                    categoryToPlay = nil
                    print("ContentView: Loading categories...")
                    viewModel.load(from: storage.categories)
                    
                    // subscribe to save events
                    viewModel.didSave.sink { categories in
                        self.saveCategories(categories: categories)
                    }.store(in: &viewModel.anyCancellable)
                }
            }
        }
    }
    
    func saveCategories(categories: [Category]) {
        print("ContentView: Saving categories...")
        self.storage.categories = categories
        self.storage.save()
        print("ContentView: Categories saved.")
    }
    
}

#Preview("with items") {
    let categories = CategoryUtilities.getPopulatedCategories(numberOfItems: 5)
    let playlistDataStore = PlaylistDataStore(
        testCategories: categories)
    return CategoryListView().environmentObject(playlistDataStore)
}

#Preview("no items") {
    let playlistDataStore = PlaylistDataStore(
        testCategories: [])
    return CategoryListView().environmentObject(playlistDataStore)
}
