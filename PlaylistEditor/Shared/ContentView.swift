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
    
    var body: some View {
        TabView {
            PlaylistsView(musicAuthorizationStatus: .constant(.notDetermined), _playlists: [])
                .tabItem {
                Label("Playlists", systemImage: "music.note.list")
            }.tag(0)
            SongsView(musicAuthorizationStatus: .constant(.notDetermined), items: []).tabItem {
                Label("Songs", systemImage: "square.and.pencil")
            }.tag(1)
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


