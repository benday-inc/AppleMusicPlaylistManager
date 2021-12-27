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
    @StateObject private var store = PlaylistDataStore()
    
    
    var body: some View {
        TabView {
            SongsView(musicAuthorizationStatus: .constant(.notDetermined), items: [])
                .environmentObject(store)
                .tabItem {
                Label("Songs", systemImage: "square.and.pencil")
            }.tag(0)
            ExclusionsView()
                .environmentObject(store)
                .tabItem {
                Label("Exclusions", systemImage: "slider.horizontal.3")
            }.tag(1)
            PlaylistsView(musicAuthorizationStatus: .constant(.notDetermined), _playlists: [])
                .tabItem {
                Label("Playlists", systemImage: "music.note.list")
            }.tag(2)
            
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


