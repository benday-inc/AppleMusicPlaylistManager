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
    @State private var newItemName = ""
    @State private var selectedItem: String?
    @State private var searchText = ""
    @State private var isSearching = false
    @Binding var isPresented: Bool
    @ObservedObject var category: CategoryViewModel
    @State public var matchingItems: [IdentifiableString] = []
    @StateObject private var debouncer = Debouncer()
    
    var body: some View {
        NavigationStack {
            List($matchingItems) { $item in
                Button(action: {
                    selectedItem = $item.wrappedValue.value
                }) {
                    Text(item.value)
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
                        newItemName = ""
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    if (selectedItem == nil || selectedItem?.isEmpty == true) {
                        Text("Select a genre above")
                            .foregroundStyle(.secondary)
                            .padding()
                    } else {
                        Text("Selected genre: \(selectedItem!)")
                            .padding()
                    }
                    
                    Button("Add") {
                        if let selectedItem {
                            let trimmed = selectedItem.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmed.isEmpty && !category.genres.contains(trimmed) {
                                category.genres.append(trimmed)
                            }
                            newItemName = ""
                            isPresented = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(
                        selectedItem == nil || selectedItem?.isEmpty == true
                    )
                }
                
            }
            .onAppear() {
                debouncer.start { genreName in
                    updateMatching(for: genreName)
                }
            }
            .navigationTitle("Add genre")
        }
        
    }
    
    private func updateMatching(for query: String) {
        guard !query.isEmpty else {
            matchingItems = []
            return
        }
        isSearching = true
        
        let mediaQuery = MPMediaQuery.genres()
        let allGenres = mediaQuery.collections?.compactMap { $0.representativeItem?.genre } ?? []
        var uniqueGenres = Array(Set(allGenres)).sorted()
        
        var returnValue = [IdentifiableString]()
        uniqueGenres = uniqueGenres.filter { $0.range(of: query, options: .caseInsensitive) != nil }
        for genre in uniqueGenres {
            returnValue.append(IdentifiableString(value: genre))
        }
        matchingItems = returnValue
        isSearching = false
    }
}

#Preview("with matching genres") {
    @Previewable @State var temp = [IdentifiableString(value: "Rock"), IdentifiableString(value: "Pop"), IdentifiableString(value: "Jazz")]
    var category = Category()
    category.name = "Test"
    let categoryVM = CategoryViewModel()
    categoryVM.load(category)
    
    return AddGenreView(isPresented: .constant(true), category: categoryVM, matchingItems: temp)
}


#Preview("empty") {
    var category = Category()
    category.name = "Test"
    let categoryVM = CategoryViewModel()
    categoryVM.load(category)
    return AddGenreView(isPresented: .constant(true), category: categoryVM)
}
