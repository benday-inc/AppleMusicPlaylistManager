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
    @State private var isAddGenreSheetPresented = false
    @State private var isAddComposerSheetPresented = false
    @State private var newGenreName = ""
    
    var body: some View {
        Form {
            Section(header: Text("Category Name")) {
                ClearableTextField(
                    text: $category.name,
                    placeholder: "Name")
            }
            Section(header: Text("Artists")) {
                List {
                    if category.artists.isEmpty {
                        Text("No artists in this category.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(category.artists, id: \.self) { artist in
                            Text(artist)
                                .swipeActions(content: {
                                    Button(role: .destructive) {
                                        if let index = category.artists.firstIndex(of: artist) {
                                            category.artists.remove(at: index)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                })
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
                                .swipeActions(content: {
                                    Button(role: .destructive) {
                                        if let index = category.genres.firstIndex(of: genre) {
                                            category.genres.remove(at: index)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                })
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
            Section(header: Text("Composers")) {
                List {
                    if category.composers.isEmpty {
                        Text("No composers in this category.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(category.composers, id: \.self) { composer in
                            Text(composer)
                                .swipeActions(content: {
                                    Button(role: .destructive) {
                                        if let index = category.composers.firstIndex(of: composer) {
                                            category.composers.remove(at: index)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                })
                        }
                    }
                    Button(action: { isAddComposerSheetPresented = true }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Add Composer")
                        }
                        .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .sheet(isPresented: $isAddArtistSheetPresented) {
            AddArtistView(isPresented: $isAddArtistSheetPresented, category: category)
        }
        .sheet(isPresented: $isAddGenreSheetPresented) {
            AddGenreView(isPresented: $isAddGenreSheetPresented, category: category)
        }
        .sheet(isPresented: $isAddComposerSheetPresented) {
            AddComposerView(isPresented: $isAddComposerSheetPresented, category: category)
        }
        .navigationTitle("Edit Category")
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button("Remove") {
                    viewModel.removeCategory()
                    dismiss()
                }
                .disabled(viewModel.selectedItem == nil || !viewModel.isLoaded)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    category.undoChanges()
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    _ = category.saveChanges()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
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
    selected.composers.append("John Dowland")
    selected.composers.append("William Byrd")
    return CategoryEditorView(category: selected, viewModel: viewModel)
}

#Preview("empty category") {
    let viewModel = CategoryListViewModel()
    let selected = viewModel.addNewCategory()
    CategoryEditorView(category: selected, viewModel: viewModel)
}
