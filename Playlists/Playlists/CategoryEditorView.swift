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
            Section(header: Text("Genres")) {
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
