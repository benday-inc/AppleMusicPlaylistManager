//
//  File.swift
//  Playlists
//
//  Created by Benjamin Day on 7/19/25.
//


import SwiftUI
import Foundation
import MediaPlayer

extension UIApplication {
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}