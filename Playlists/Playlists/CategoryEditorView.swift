//
//  CategoryEditorView.swift
//  Playlists
//
//  Created by Benjamin Day on 6/19/25.
//

import SwiftUI

struct CategoryEditorView: View {
    @ObservedObject var category: CategoryViewModel
    @ObservedObject var viewModel: CategoryListViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isAddArtistSheetPresented = false
    @State private var newArtistName = ""
    @State private var isAddGenreSheetPresented = false
    @State private var newGenreName = ""
    
    var body: some View {
        Form {
            Section(header: Text("Category Name")) {
                TextField("Name", text: $category.name)
            }
            Section(header: Text("Artists")) {
                List {
                    if category.artists.isEmpty {
                        
                        Text("No artists in this category.")
                            .foregroundColor(.secondary)
                        
                    } else {
                        ForEach(category.artists, id: \.self) { artist in
                            Text(artist)
                        }
                    }
                    
                    Button(action: { isAddArtistSheetPresented = true }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Add Artist")
                        }
                        .foregroundColor(.accentColor)
                    }
                }
            }
            Section(header: Text("Genres")) {
                List {
                    if category.genres.isEmpty {
                        Text("No genres in this category.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(category.genres, id: \.self) { genre in
                            Text(genre)                            
                        }
                    }
                    Button(action: { isAddGenreSheetPresented = true }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Add Genre")
                        }
                        .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .sheet(isPresented: $isAddArtistSheetPresented) {
            NavigationStack {
                VStack(spacing: 16) {
                    Text("Add Artist")
                        .font(.headline)
                    TextField("Artist name", text: $newArtistName)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    Button("Add") {
                        let trimmed = newArtistName.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty && !category.artists.contains(trimmed) {
                            category.artists.append(trimmed)
                        }
                        newArtistName = ""
                        isAddArtistSheetPresented = false
                    }
                    .disabled(newArtistName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    Spacer()
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            isAddArtistSheetPresented = false
                            newArtistName = ""
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isAddGenreSheetPresented) {
            NavigationStack {
                VStack(spacing: 16) {
                    Text("Add Genre")
                        .font(.headline)
                    TextField("Genre name", text: $newGenreName)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    Button("Add") {
                        let trimmed = newGenreName.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty && !category.genres.contains(trimmed) {
                            category.genres.append(trimmed)
                        }
                        newGenreName = ""
                        isAddGenreSheetPresented = false
                    }
                    .disabled(newGenreName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    Spacer()
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            isAddGenreSheetPresented = false
                            newGenreName = ""
                        }
                    }
                }
            }
        }
        .navigationTitle("Edit Category")
        .toolbar {
            Button("Remove") {
                viewModel.removeCategory()
                dismiss()
            }
            .disabled(viewModel.selectedItem == nil || !viewModel.isLoaded)
        }
        .onAppear {
            print("CategoryEditorView onAppear")
            viewModel.selectedItem = category
        }
    }
}

#Preview("non-empty category") {
    let viewModel = CategoryListViewModel()
    let selected = viewModel.addNewCategory()
    
    selected.artists.append("Artist 1")
    selected.artists.append("Artist 2")
    selected.genres.append("Genre A")
    selected.genres.append("Genre B")
    
    return CategoryEditorView(category: selected, viewModel: viewModel)
}

#Preview("empty category") {
    let viewModel = CategoryListViewModel()
    let selected = viewModel.addNewCategory()
    CategoryEditorView(category: selected, viewModel: viewModel)
}
