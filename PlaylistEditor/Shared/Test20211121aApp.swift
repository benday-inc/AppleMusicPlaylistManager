//
//  Test20211121aApp.swift
//  Shared
//
//  Created by Benjamin Day on 11/21/21.
//

import SwiftUI

@main
struct Test20211121aApp: App {
    var body: some Scene {
        WindowGroup {
            if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil {
                ContentView(musicAuthorizationStatus: .notDetermined)
                    .navigationTitle("Random Playlist Generator")
            }
        }
    }
}
