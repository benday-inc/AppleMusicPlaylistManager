//
//  AddComposerView.swift
//  Playlists
//
//  Created by Benjamin Day on 6/19/25.
//

import SwiftUI
import Foundation
import MediaPlayer

struct AddComposerView: View {
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
            .searchable(text: $searchText, prompt: "Search for composers")
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
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 0) {
                    Divider()
                    HStack {
                        if selectedItems.isEmpty {
                            Text("Select composer(s) above")
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Selected: \(getSelectedText())")
                                .foregroundStyle(.primary)
                        }
                        Spacer()
                        Button("Add") {
                            let trimmedItems = selectedItems.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                            let newItems = trimmedItems.filter { !$0.isEmpty && !category.composers.contains($0) }
                            category.composers.append(contentsOf: newItems)
                            newItemName = ""
                            isPresented = false
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(selectedItems.isEmpty)
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                }
            }
            .onAppear() {
                debouncer.start { composerName in
                    updateMatching(for: composerName)
                }
            }
            .navigationTitle("Add composer")
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
        let mediaQuery = MPMediaQuery.composers()
        let allComposers = mediaQuery.collections?.compactMap { $0.representativeItem?.composer } ?? []
        var uniqueComposers = Array(Set(allComposers)).sorted()

        var returnValue = [IdentifiableString]()
        uniqueComposers = uniqueComposers.filter { $0.range(of: query, options: .caseInsensitive) != nil }
        for composer in uniqueComposers {
            returnValue.append(IdentifiableString(value: composer))
        }
        matchingItems = returnValue
    }
}

#Preview("with matching composers") {
    @Previewable @State var temp = [
        IdentifiableString(value: "John Dowland"),
        IdentifiableString(value: "William Byrd"),
        IdentifiableString(value: "Palestrina"),
        IdentifiableString(value: "Thomas Tallis"),
        IdentifiableString(value: "Johann Sebastian Bach")]
    var category = Category()
    category.name = "Test"
    let categoryVM = CategoryViewModel()
    categoryVM.load(category)

    return AddComposerView(isPresented: .constant(true), category: categoryVM, matchingItems: temp)
}

#Preview("empty") {
    var category = Category()
    category.name = "Test"
    let categoryVM = CategoryViewModel()
    categoryVM.load(category)
    return AddComposerView(isPresented: .constant(true), category: categoryVM)
}
