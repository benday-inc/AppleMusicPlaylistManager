//
//  SongsView.swift
//  PlaylistEditor (iOS)
//
//  Created by Benjamin Day on 12/26/21.
//

import SwiftUI
import MusicKit
import MediaPlayer

struct SongsView: View {
    /// Opens a URL using the appropriate system service.
    @Environment(\.openURL) private var openURL

    @State var doSomethingText = "(not set)"
    /// The current authorization status of MusicKit.
    @Binding var musicAuthorizationStatus: MusicAuthorization.Status
    
    @State var _items: Array<MediaItemWrapper>
    
    @State var itemCount: Int = -1
    
    var body: some View {
        
        NavigationView {
            VStack {
                List {
                    ForEach(_items) { item in
                        SongCell(item: item)
                    }
                }
                Text("Item count: \(itemCount)")
            }
            
            
            .navigationTitle("Songs")
            .toolbar{
                HStack {
//                        Button(action: handleButtonPressed) {
//                            buttonText
//                        }
                    
                    Button("songs", action: handleGetAllSongs)
                }
            }
        }.navigationViewStyle(.stack)
        
    }
    
    private func handleGetAllSongs() {
        
        print("getting all songs...")
        let query = MPMediaQuery.songs()
        let queryResults = query.items
        print("got all songs.")
        
        itemCount = queryResults?.count ?? -1
                
        var temp = Array<MediaItemWrapper>()
        
        for case let item as MPMediaItem in queryResults! {
            temp.append(MediaItemWrapper(item: item))
        }
        
        _items = temp
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
                buttonText = Text("permissions")
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



struct SongsView_Previews: PreviewProvider {
    static var previews: some View {
        SongsView(musicAuthorizationStatus: .constant(.notDetermined),_items: [ MediaItemWrapper(trackName: "track name 1", albumName: "album name 1", artistName: "artist name 1"),                                                                            MediaItemWrapper(trackName: "track name 2", albumName: "album name 2", artistName: "artist name 2"),                                                                            MediaItemWrapper(trackName: "track name 3", albumName: "album name 3", artistName: "artist name 3")])
.previewInterfaceOrientation(.portrait)
    }
}
