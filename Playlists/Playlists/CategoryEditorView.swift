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

    var body: some View {
        NavigationStack {
            Text(category.name)
                .font(.largeTitle)
        }
        .navigationTitle("Edit Category")
        .toolbar {
//                Button("Add") { _ = viewModel.addNewCategory() }
//                    .disabled(!viewModel.isLoaded)
                Button("Remove") { viewModel.removeCategory() }
                    .disabled(viewModel.selectedItem == nil || !viewModel.isLoaded)
        }
        .onAppear {
            print("CategoryEditorView onAppear")
            // viewModel.selectedItem = category
        }
        
    }
        
        
    
}

#Preview {
    let viewModel = CategoryListViewModel()
    
    let selected = viewModel.addNewCategory()
    
    CategoryEditorView(category: selected, viewModel: viewModel)
}
