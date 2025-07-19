//
//  ClearableTextField.swift
//  Playlists
//
//  Created by Benjamin Day on 7/19/25.
//


import SwiftUI

struct ClearableTextField: View {
    @Binding var text: String
    @Binding var placeholder: String

    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .textFieldStyle(.roundedBorder)
                .overlay(
                    HStack {
                        Spacer()
                        if !text.isEmpty {
                            Button(action: { text = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing, 8)
                        }
                    }
                )
        }
    }
}
