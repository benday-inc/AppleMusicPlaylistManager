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
    @State var doSomethingText = "(not set)"
    /// The current authorization status of MusicKit.
    @Binding var musicAuthorizationStatus: MusicAuthorization.Status
    
    @State var _playlists: Array<PlaylistItem>
    
    
    /// Opens a URL using the appropriate system service.
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        VStack {
            VStack {
                Text("Hello, world!")
                    .padding()
                Button("do something", action: handleDoSomething)
                Label(doSomethingText, systemImage: /*@START_MENU_TOKEN@*/"42.circle"/*@END_MENU_TOKEN@*/)
                Button(action: handleButtonPressed) {
                    buttonText
                        .padding([.leading, .trailing], 10)
                }
                Button("get playlists", action: handleListPlaylists)
                
                Button("get all songs", action: handleGetAllSongs)
            }
            List {
                ForEach(_playlists) { item in
                    Text("\(item.name)")
                }
            }
        }
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
        
        for playlist in playlists! {
            let tempAny = playlist.value(forProperty: MPMediaPlaylistPropertyName) as! String
            
            
            temp.append(PlaylistItem(name: tempAny))
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
    
    /// Allows the user to authorize Apple Music usage when tapping the Continue/Open Setting button.
    private func handleButtonPressed() {
        switch musicAuthorizationStatus {
            case .notDetermined:
                Task {
                    let musicAuthorizationStatus = await MusicAuthorization.request()
                    await update(with: musicAuthorizationStatus)
                }
            case .denied:
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    openURL(settingsURL)
                }
            default:
                fatalError("No button should be displayed for current authorization status: \(musicAuthorizationStatus).")
        }
    }
    
    /// A button that the user taps to continue using the app according to the current
    /// authorization status.
    private var buttonText: Text {
        let buttonText: Text
        switch musicAuthorizationStatus {
            case .notDetermined:
                buttonText = Text("Check for media library permissions")
            case .denied:
                buttonText = Text("Open Settings")
            default:
                fatalError("No button should be displayed for current authorization status: \(musicAuthorizationStatus).")
        }
        return buttonText
    }
    
    /// Safely updates the `musicAuthorizationStatus` property on the main thread.
    @MainActor
    private func update(with musicAuthorizationStatus: MusicAuthorization.Status) {
        withAnimation {
            self.musicAuthorizationStatus = musicAuthorizationStatus
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(musicAuthorizationStatus: .constant(.notDetermined), _playlists: [ PlaylistItem(name: "one"),PlaylistItem(name: "two"),PlaylistItem(name: "three"),PlaylistItem(name: "four")])
    }
}
