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
        NavigationStack {
            Text(category.name)
                .font(.largeTitle)
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
