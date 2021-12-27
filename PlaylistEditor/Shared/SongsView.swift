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
    @EnvironmentObject var storage: PlaylistDataStore
    
    @State var items: Array<MediaItemWrapper>
    @State var allItems: Array<MediaItemWrapper>?
    
    @State var itemCount: Int = -1
    @State private var multiSelection = Set<UUID>()
    
    var body: some View {
        
        NavigationView {
            VStack {
                List(items, selection: $multiSelection) { temp in
                    SongCell(item: temp)
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            
                            Button("album", role: .destructive) {
                                storage.addAlbumExclusion(item: temp)
                            }
                            Button("track", role: .destructive) {
                                print("exclude track: \(temp.trackName)")
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            
                            Button("genre", role: .destructive) {
                                storage.addGenreExclusion(item: temp)
                            }
                            Button("artist", role: .destructive) {
                                storage.addArtistExclusion(item: temp)
                            }
                        }
                }
                
                Text("Item count: \(itemCount)")
                Button("Create Playlist", action: writePlaylist)
            }
            
            
            .navigationTitle("Songs")
            .toolbar{
                HStack {
//                        Button(action: handleButtonPressed) {
//                            buttonText
//                        }
                    EditButton()
                    Button("all songs", action: handleGetAllSongs)
                    Button("random songs", action: handleGetRandomSongs)
                }
            }
        }.navigationViewStyle(.stack)
        
    }
    
    private func writePlaylist() {
        let now = Date()
        let calendar = Calendar.current

        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let second = calendar.component(.second, from: now)
        
        
        let name = "playlist \(year)\(month)\(day)_\(hour)\(minute)\(second)"
        let metadata = MPMediaPlaylistCreationMetadata(name: name)
        
        let playlistUUID = UUID()

        MPMediaLibrary.default().getPlaylist(with: playlistUUID, creationMetadata: metadata) { (playlist, error) in
            guard error == nil else {
                fatalError("An error occurred while retrieving/creating playlist: \(error!.localizedDescription)")
            }
            
        }
    }
    
    private func handleGetAllSongs() {
        
        print("getting all songs...")
        let query = MPMediaQuery.songs()
        let queryResults = query.items
        print("got all songs.")
        
        itemCount = queryResults?.count ?? -1
                
        var temp = Array<MediaItemWrapper>()
                
        for item in queryResults! {
            temp.append(MediaItemWrapper(item: item))
        }
        
        items = temp
        allItems = temp
    }
    
    private func getRandomIndexes(maxIndex: Int, numberOfValuesToReturn: Int) -> Array<Int> {
        var returnValues = Array<Int>()
        
        for _ in 0...numberOfValuesToReturn {
            returnValues.append(Int.random(in: 1..<maxIndex))
        }
        
        return returnValues
    }
    
    private func handleGetRandomSongs() {
        
        let songCount = allItems!.count
                
        let randomIndexes = getRandomIndexes(maxIndex: songCount, numberOfValuesToReturn: 100)
        
        var temp = Array<MediaItemWrapper>()
        
        for index in randomIndexes {
            let tempSong = allItems![index]
            
            if (storage.isExcluded(item: tempSong) == false) {
                temp.append(tempSong)
                print("not excluded")
            }
            else {
                print("excluded")
            }
        }
                
        items = temp
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
        SongsView(musicAuthorizationStatus: .constant(.notDetermined), items: [ MediaItemWrapper(trackName: "track name 1", albumName: "album name 1", artistName: "artist name 1"),                                                                            MediaItemWrapper(trackName: "track name 2", albumName: "album name 2", artistName: "artist name 2"),                                                                            MediaItemWrapper(trackName: "track name 3", albumName: "album name 3", artistName: "artist name 3")])
            .environmentObject(PlaylistDataStore())
.previewInterfaceOrientation(.portrait)
    }
}
