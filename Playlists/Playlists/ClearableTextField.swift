//
//  ClearableTextField.swift
//  Playlists
//
//  Created by Benjamin Day on 7/19/25.
//


import SwiftUI

struct ClearableTextField: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
                .disabled(text.isEmpty)            
        }
    }
}
