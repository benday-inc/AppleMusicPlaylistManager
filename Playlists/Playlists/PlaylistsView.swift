//
//  PlaylistsView.swift
//  RandomPlaylistGenerator (iOS)
//
//  Created by Benjamin Day on 12/26/21.
//

import SwiftUI
import MusicKit
import MediaPlayer

struct PlaylistsView: View {
    /// Opens a URL using the appropriate system service.
    @Environment(\.openURL) private var openURL

    @State var doSomethingText = "(not set)"
    /// The current authorization status of MusicKit.
    
    @State var _playlists: Array<PlaylistItem>
    
    var body: some View {
        
        NavigationView {
            List {
                ForEach(_playlists) { item in
                    PlaylistCell(playlist: item)
                }
            }
            .navigationTitle("Playlists")
            .toolbar{
                HStack {
//                        Button(action: handleButtonPressed) {
//                            buttonText
//                        }
                    Button("playlists", action: handleListPlaylists)
                    
                    Button("songs", action: handleGetAllSongs)
                }
            }
        }.navigationViewStyle(.stack)
        
    }
    
    private func handleDoSomething() {
        let settingsUrl = UIApplication.openSettingsURLString
        
        doSomethingText = settingsUrl
    }
    
    private func handleGetAllSongs() {
        print("getting all songs...")
        let songs = MPMediaQuery.songs()
        
        print("got all songs.")
        
        print("song count: \(songs.items?.count ?? -1)")
    }
    
    private func handleListPlaylists() {
        let myPlaylistQuery = MPMediaQuery.playlists()
        let playlists = myPlaylistQuery.collections
        
        var temp = Array<PlaylistItem>()
        
        for case let playlist as MPMediaPlaylist in playlists! {
            temp.append(PlaylistItem(name: playlist.name!, instance: playlist))
        }
        
        _playlists = temp
    }
    
    private func handleListPlaylistsAndSongsInPlaylists() {
        let myPlaylistQuery = MPMediaQuery.playlists()
        let playlists = myPlaylistQuery.collections
        for playlist in playlists! {
            print(playlist.value(forProperty: MPMediaPlaylistPropertyName)!)
                    
            let songs = playlist.items
            for song in songs {
                let songTitle = song.value(forProperty: MPMediaItemPropertyTitle)
                print("\t\t", songTitle!)
            }
        }
    }
    
    
}



struct PlaylistsView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistsView(_playlists: [ PlaylistItem(name: "one"),PlaylistItem(name: "two"),PlaylistItem(name: "three threethree threethree threethree threethree threethree threethree threethree threethree threethree threethree threethree three"),PlaylistItem(name: "four")])
.previewInterfaceOrientation(.landscapeLeft)
    }
}
