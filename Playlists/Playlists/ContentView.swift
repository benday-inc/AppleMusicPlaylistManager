//
//  ContentView.swift
//  Shared
//
//  Created by Benjamin Day on 11/21/21.
//

import SwiftUI
import MusicKit
import MediaPlayer

struct ContentView: View {
    @EnvironmentObject private var storage: PlaylistDataStore
    @State var musicAuthorizationStatus: MusicAuthorization.Status
    
    var body: some View {
        MusicLibraryAuthorizationView(authorizationStatus: $musicAuthorizationStatus)
        
        if (musicAuthorizationStatus == .authorized)         {
            if (storage.isLoaded == false) {
                Text("Loading...")
                    .onAppear() {
                        Task {
                            await storage.load()
                        }
                    }
            }
            else {
                TabView {
                    CategoryListView()
                        .environmentObject(storage)
                        .tabItem {
                            Label("Categories", systemImage: "list.bullet")
                        }.tag(0)
                    
                    SongsView(storage)
                        .tabItem {
                            Label("Build Playlist", systemImage: "square.and.pencil")
                        }.tag(1)
                    ExclusionsView()
                        .environmentObject(storage)
                        .tabItem {
                            Label("Playlist Exclusions", systemImage: "slider.horizontal.3")
                        }.tag(2)
//                    PlaylistsView(_playlists: [])
//                        .tabItem {
//                            Label("Playlists", systemImage: "music.note.list")
//                        }.tag(2)
                    AboutView()
                        .tabItem {
                            Label("About", systemImage: "info.bubble")
                        }.tag(3)
                    
                }
            }
        }
    }

    
    
    func requestMusicAuthorization() async -> MusicAuthorization.Status {
        let currentStatus = MusicAuthorization.currentStatus
        
        if (currentStatus == .notDetermined)
        {
            let status = await MusicAuthorization.request()
            
            return status
        }
        else {
            print("returning current status: \(currentStatus)")
            return currentStatus
        }
    }
    
    /// Allows the user to authorize Apple Music usage when tapping the Continue/Open Setting button.
    private func handleButtonPressed() async {
        print("requesting music auth status...")
        
        let status = await requestMusicAuthorization()
        
        print("returned music auth status: \(musicAuthorizationStatus)...")
        
        musicAuthorizationStatus = status
    }
}

#Preview("categories") {
    let categories = CategoryUtilities.getPopulatedCategories(numberOfItems: 5)
    let playlistDataStore = PlaylistDataStore(
        testCategories: categories)
    ContentView(musicAuthorizationStatus: .authorized)
        .environmentObject(playlistDataStore)
}

#Preview("no categories") {
    ContentView(musicAuthorizationStatus: .authorized)
}



