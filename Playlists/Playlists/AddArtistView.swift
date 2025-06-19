//
//  AddartistView.swift
//  Playlists
//
//  Created by Benjamin Day on 6/19/25.
//

import SwiftUI
import Foundation
import MediaPlayer

struct AddArtistView: View {
    @State private var newItemName = ""
    @State private var selectedItem: String?
    @State private var searchText = ""
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
            .searchable(text: $searchText, prompt: "Search for artists")
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
                        Text("Select a artist above")
                            .foregroundStyle(.secondary)
                            .padding()
                    } else {
                        Text("Selected artist: \(selectedItem!)")
                            .padding()
                    }
                    
                    Button("Add") {
                        if let selectedItem {
                            let trimmed = selectedItem.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmed.isEmpty && !category.artists.contains(trimmed) {
                                category.artists.append(trimmed)
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
                debouncer.start { artistName in
                    updateMatchingartists(for: artistName)
                }
            }
            .navigationTitle("Add artist")
        }
        
    }
    
    private func updateMatchingartists(for query: String) {
        guard !query.isEmpty else {
            matchingItems = []
            return
        }
        let mediaQuery = MPMediaQuery.artists()
        let allartists = mediaQuery.collections?.compactMap { $0.representativeItem?.artist } ?? []
        var uniqueArtists = Array(Set(allartists)).sorted()
        
        var returnValue = [IdentifiableString]()
        uniqueArtists = uniqueArtists.filter { $0.range(of: query, options: .caseInsensitive) != nil }
        for artist in uniqueArtists {
            returnValue.append(IdentifiableString(value: artist))
        }
        matchingItems = returnValue
    }
}

#Preview("with matching artists") {
    @Previewable @State var temp = [IdentifiableString(value: "Rock"), IdentifiableString(value: "Pop"), IdentifiableString(value: "Jazz")]
    var category = Category()
    category.name = "Test"
    var categoryVM = CategoryViewModel()
    categoryVM.load(category)
    
    return AddArtistView(isPresented: .constant(true), category: categoryVM, matchingItems: temp)
}


#Preview("empty") {
    var category = Category()
    category.name = "Test"
    var categoryVM = CategoryViewModel()
    categoryVM.load(category)
    return AddArtistView(isPresented: .constant(true), category: categoryVM)
}
