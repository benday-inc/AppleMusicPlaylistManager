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
    @State private var selectedItems: Set<String> = []
    @State private var editMode = EditMode.active
    @State private var searchText = ""
    @State private var isSearching = false
    @Binding var isPresented: Bool
    @ObservedObject var category: CategoryViewModel
    @State public var matchingItems: [IdentifiableString] = []
    @StateObject private var debouncer = Debouncer()
    
    var body: some View {
        NavigationStack {
            List(matchingItems, id: \.value, selection: $selectedItems) { item in
                Text(item.value)
                    .onTapGesture {
                        UIApplication.shared.dismissKeyboard()
                        if selectedItems.contains(item.value) {
                            selectedItems.remove(item.value)
                        } else {
                            selectedItems.insert(item.value)
                        }
                    }
            }
            .environment(\.editMode, $editMode)
            .searchable(text: $searchText, prompt: "Search for genres")
            .onChange(of: searchText) { oldValue, newValue in
                let trimmed = newValue.trimmingCharacters(in: .whitespaces)
                debouncer.input.send(trimmed)
            }
            .onChange(of: selectedItems) {
                UIApplication.shared.dismissKeyboard()
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
                            Text("Select genres(s) above")
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
                            let newItems = trimmedItems.filter { !$0.isEmpty && !category.genres.contains($0) }
                            category.genres.append(contentsOf: newItems)
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
                debouncer.start { genreName in
                    updateMatching(for: genreName)
                }
            }
            .navigationTitle("Add genre")
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
    @Previewable @State var temp = [IdentifiableString(value: "Rock"), IdentifiableString(value: "Pop"),
                                    IdentifiableString(value: "Pop 1"), IdentifiableString(value: "Pop 2"), IdentifiableString(value: "Pop 3"), IdentifiableString(value: "Jazz"),
                                    IdentifiableString(value: "Latin Jazz")
    ]
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


