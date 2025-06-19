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
    @State private var searchText = ""
    @Binding var isPresented: Bool
    @ObservedObject var category: CategoryViewModel
    @State public var matchingGenres: [IdentifiableString] = []
    @StateObject private var debouncer = Debouncer()
    
    var body: some View {
        NavigationStack {
            List($matchingGenres) { $genre in
                Button(action: {
                    selectedGenre = $genre.wrappedValue.value
                }) {
                    Text(genre.value)
                }.buttonStyle(.plain)
            }
            .searchable(text: $searchText, prompt: "Search for genres")
            .onChange(of: searchText) { oldValue, newValue in
                let trimmed = newValue.trimmingCharacters(in: .whitespaces)
                debouncer.input.send(trimmed)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                        newGenreName = ""
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    if (selectedGenre == nil || selectedGenre?.isEmpty == true) {
                        Text("Select a genre above")
                            .foregroundStyle(.secondary)
                            .padding()
                    } else {
                        Text("Selected genre: \(selectedGenre!)")
                            .padding()
                    }
                    
                    Button("Add") {
                        if let selectedGenre {
                            let trimmed = selectedGenre.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmed.isEmpty && !category.genres.contains(trimmed) {
                                category.genres.append(trimmed)
                            }
                            newGenreName = ""
                            isPresented = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(
                        selectedGenre == nil || selectedGenre?.isEmpty == true
                    )
                }
                
            }
            .onAppear() {
                debouncer.start { genreName in
                    updateMatchingGenres(for: genreName)
                }
            }
            .navigationTitle("Add Genre")
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

#Preview("with matching genres") {
    @Previewable @State var temp = [IdentifiableString(value: "Rock"), IdentifiableString(value: "Pop"), IdentifiableString(value: "Jazz")]
    var category = Category()
    category.name = "Test"
    var categoryVM = CategoryViewModel()
    categoryVM.load(category)
    
    return AddGenreView(isPresented: .constant(true), category: categoryVM, matchingGenres: temp)
}


#Preview("empty") {
    var category = Category()
    category.name = "Test"
    var categoryVM = CategoryViewModel()
    categoryVM.load(category)
    return AddGenreView(isPresented: .constant(true), category: categoryVM)
}
