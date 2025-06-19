//
//  AddArtistView.swift
//  Playlists
//
//  Created by Benjamin Day on 6/19/25.
//

import SwiftUI
import Foundation

struct AddArtistView: View {
    @State private var newArtistName = ""
    @Binding var isPresented: Bool
    @ObservedObject var category: CategoryViewModel
    
    var body: some View {
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
                    isPresented = false
                }
                .disabled(newArtistName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                        newArtistName = ""
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
    return AddArtistView(isPresented: .constant(true), category: categoryVM)
    
}
