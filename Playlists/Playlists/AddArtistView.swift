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
    @State private var selectedItems: Set<String> = []
    @State private var editMode = EditMode.active
    @State private var searchText = ""
    @Binding var isPresented: Bool
    @ObservedObject var category: CategoryViewModel
    @State public var matchingItems: [IdentifiableString] = []
    @StateObject private var debouncer = Debouncer()
    
    var body: some View {
        NavigationStack {
            List(matchingItems, id: \.value, selection: $selectedItems) { item in
                Text(item.value)
            }
            .environment(\.editMode, $editMode)
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
                    HStack {
                        if selectedItems.isEmpty {
                            Text("Select artist(s) above")
                                .foregroundStyle(.secondary)
                                .padding()
                            Spacer()
                        } else {
                            let text = getSelectedText()
                            
                            
                            Text("Selected: \(text)")
                                .padding()
                            Spacer()
                        }
                        
                        Button("Add") {
                            let trimmedItems = selectedItems.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                            let newItems = trimmedItems.filter { !$0.isEmpty && !category.artists.contains($0) }
                            category.artists.append(contentsOf: newItems)
                            newItemName = ""
                            isPresented = false
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(selectedItems.isEmpty)
                        .frame(minWidth: 80)
                    }                    
                    
                }
                
            }
            .onAppear() {
                debouncer.start { artistName in
                    updateMatching(for: artistName)
                }
            }
            .navigationTitle("Add artist")
        }
        
    }
    
    private func getSelectedText() -> String {
        let joined = selectedItems.joined(separator: ", ")

        if (UIDevice.current.userInterfaceIdiom == .phone) {
            let orientation = UIDevice.current.orientation
            
            let maxChars : Int
            
            if (orientation.isLandscape == true) {
                maxChars = 60
            }
            else
            {
                maxChars = 15
            }
                
            let text = joined.count > maxChars
                ? joined.prefix(maxChars) + "…"
                : joined

            return text
        }
        else {
            let maxChars = 80
            
            if (joined.count > maxChars) {
                return joined.prefix(maxChars) + "…"
            }
            else {
                return joined
            }
        }
    }
    
    private func updateMatching(for query: String) {
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
    @Previewable @State var temp = [
        IdentifiableString(value: "Bob Bobbenbobber"),
        IdentifiableString(value: "Bobbenbobber"),
        IdentifiableString(value: "Sneeze"),
        IdentifiableString(value: "Pumpkin"),
        IdentifiableString(value: "Big Long Name That is Super Long 1"),
        IdentifiableString(value: "Big Long Name That is Super Long 2"),
        IdentifiableString(value: "Big Long Name That is Super Long 3"),
        IdentifiableString(value: "Big Long Name That is Super Long 4"),
        IdentifiableString(value: "Junk n Stuff")]
    var category = Category()
    category.name = "Test"
    let categoryVM = CategoryViewModel()
    categoryVM.load(category)
    
    return AddArtistView(isPresented: .constant(true), category: categoryVM, matchingItems: temp)
}


#Preview("empty") {
    var category = Category()
    category.name = "Test"
    let categoryVM = CategoryViewModel()
    categoryVM.load(category)
    return AddArtistView(isPresented: .constant(true), category: categoryVM)
}
