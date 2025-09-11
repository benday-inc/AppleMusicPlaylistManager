//
//  PlaylistsApp.swift
//  Playlists
//
//  Created by Benjamin Day on 6/3/25.
//

import SwiftUI

@main
struct PlaylistsApp: App {
    // Use the shared instance to ensure data consistency between main app and CarPlay
    @StateObject private var storage = PlaylistDataStore.shared
    
    var body: some Scene {
        WindowGroup {
            if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil {
                ContentView(musicAuthorizationStatus: .notDetermined)
                    .navigationTitle("Random Playlist Generator")
                    .environmentObject(storage)
            }
        }
    }
}
