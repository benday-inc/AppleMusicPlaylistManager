
//
//  AddGenreView.swift
//  Playlists
//
//  Created by Benjamin Day on 6/19/25.
//

import SwiftUI
import Foundation

struct AddGenreView: View {
    @State private var newGenreName = ""
    @Binding var isPresented: Bool
    @ObservedObject var category: CategoryViewModel
    
    var body: some View {
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
                    isPresented = false
                }
                .disabled(newGenreName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                        newGenreName = ""
                    }
                }
            }
        }
    }
}

#Preview {
    var category = Category()
    category.name = "Test"
    var categoryVM = CategoryViewModel()
    categoryVM.load(category)
    return AddGenreView(isPresented: .constant(true), category: categoryVM)
    
}
