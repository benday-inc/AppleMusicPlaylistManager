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
    @StateObject private var storage = PlaylistDataStore()
    
    
    var body: some View {
        TabView {
            SongsView(musicAuthorizationStatus: .constant(.notDetermined), items: [])
                .environmentObject(storage)
                .tabItem {
                    Label("Songs", systemImage: "square.and.pencil")
                }.tag(0)
            ExclusionsView()
                .environmentObject(storage)
                .tabItem {
                    Label("Exclusions", systemImage: "slider.horizontal.3")
                }.tag(1)
            PlaylistsView(musicAuthorizationStatus: .constant(.notDetermined), _playlists: [])
                .tabItem {
                    Label("Playlists", systemImage: "music.note.list")
                }.tag(2)
            
        }.onAppear {
            storage.load()
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


