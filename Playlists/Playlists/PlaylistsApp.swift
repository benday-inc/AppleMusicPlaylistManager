//
//  PlaylistsApp.swift
//  Playlists
//
//  Created by Benjamin Day on 6/3/25.
//

import SwiftUI

@main
struct PlaylistsApp: App {
    // @StateObject var storage = PlaylistDataStore()
    @StateObject private var storage = PlaylistDataStore()
    
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
