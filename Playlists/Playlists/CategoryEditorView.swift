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

    var body: some View {
        Form {
            Section(header: Text("Category Name")) {
                TextField("Name", text: $category.name)
            }
            Section(header: Text("Artists")) {
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
