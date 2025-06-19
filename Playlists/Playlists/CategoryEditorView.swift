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
            Section(header: HStack {
                Text("Artists")
                Spacer()
                Button(action: { isAddArtistSheetPresented = true }) {
                    Image(systemName: "plus.circle")
                }
                .accessibilityLabel("Add Artist")
            }) {
                if category.artists.isEmpty {
                    Text("No artists in this category.")
                        .foregroundColor(.secondary)
                } else {
                    List(category.artists, id: \.self) { artist in
                        Text(artist)
                    }
                }
            }
            Section(header: HStack {
                Text("Genres")
                Spacer()
                Button(action: { isAddGenreSheetPresented = true }) {
                    Image(systemName: "plus.circle")
                }
                .accessibilityLabel("Add Genre")
            }) {
                if category.genres.isEmpty {
                    Text("No genres in this category.")
                        .foregroundColor(.secondary)
                } else {
                    List(category.genres, id: \.self) { genre in
                        Text(genre)
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

#Preview {
    let viewModel = CategoryListViewModel()
    let selected = viewModel.addNewCategory()
    CategoryEditorView(category: selected, viewModel: viewModel)
}
