//
//  AddGenreView.swift
//  Playlists
//
//  Created by Benjamin Day on 6/19/25.
//

import SwiftUI
import Foundation
import MediaPlayer

struct AddGenreView: View {
    @State private var newGenreName = ""
    @State private var selectedGenre: String?
    @Binding var isPresented: Bool
    @ObservedObject var category: CategoryViewModel
    @State private var matchingGenres: [IdentifiableString] = []
    @StateObject private var debouncer = Debouncer()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Add Genre")
                    .font(.headline)
                TextField("Genre name", text: $newGenreName)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .onChange(of: newGenreName) { oldValue, newValue in
                        let trimmed = newValue.trimmingCharacters(in: .whitespaces)
                        
                        debouncer.input.send(trimmed)
                    }
                if !matchingGenres.isEmpty {
                    List($matchingGenres) { $genre in
                        Button(action: {
                            selectedGenre = $genre.wrappedValue.value
                        }) {
                            Text(genre.value)
                        }
                    }
                }
                else {
                    Text("no matching genres")
                }
                Button("Add") {
                    let trimmed = newGenreName.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty && !category.genres.contains(trimmed) {
                        category.genres.append(trimmed)
                    }
                    newGenreName = ""
                    isPresented = false
                }
                .disabled(selectedGenre == nil || newGenreName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
            .onAppear() {
                debouncer.start { genreName in
                    updateMatchingGenres(for: genreName)
                }
            }
        }
    }
    
    private func updateMatchingGenres(for query: String) {
        guard !query.isEmpty else {
            matchingGenres = []
            return
        }
        let mediaQuery = MPMediaQuery.genres()
        let allGenres = mediaQuery.collections?.compactMap { $0.representativeItem?.genre } ?? []
        var uniqueGenres = Array(Set(allGenres)).sorted()
        
        var returnValue = [IdentifiableString]()
        uniqueGenres = uniqueGenres.filter { $0.range(of: query, options: .caseInsensitive) != nil }
        for genre in uniqueGenres {
            returnValue.append(IdentifiableString(value: genre))
        }
        matchingGenres = returnValue
    }
}

#Preview {
    var category = Category()
    category.name = "Test"
    var categoryVM = CategoryViewModel()
    categoryVM.load(category)
    return AddGenreView(isPresented: .constant(true), category: categoryVM)
}
