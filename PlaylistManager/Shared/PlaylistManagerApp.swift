//
//  PlaylistManagerApp.swift
//  Shared
//
//  Created by Benjamin Day on 11/20/21.
//

import SwiftUI

@main
struct PlaylistManagerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
