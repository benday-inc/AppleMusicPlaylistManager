//
//  SongsView.swift
//  RandomPlaylistGenerator (iOS)
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
    @Environment(\.editMode) var editMode
    @Environment(\.isPreview) var isPreview
    @State var isAuthorizedForMusic: Bool = false
    
    
    var body: some View {
        
        NavigationView {
            VStack {
                let _ = print("***** authorization status: \(musicAuthorizationStatus)")
                if (isAuthorizedForMusic == true) {
                    List(selection: $multiSelection) {
                        ForEach (items) { item in
                            SongCell(item: item)
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                
                                Button("album", role: .destructive) {
                                    storage.addAlbumExclusion(item: item)
                                }
                                Button("track", role: .destructive) {
                                    print("exclude track: \(item.trackName)")
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                
                                Button("genre", role: .destructive) {
                                    storage.addGenreExclusion(item: item)
                                }
                                Button("artist", role: .destructive) {
                                    storage.addArtistExclusion(item: item)
                                }
                            }
                        }
                        .onMove(perform: move)
                    }
                }
                else {
                    Text("We need to get your permission to access your music library.")
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)

                    Button("Click here to start the authorization process.", action: {
                        Task {
                            print("*** calling handle button press")
                            await handleButtonPressed()
                            print("*** called handle button press")
                        }
                    })
                    
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        .padding(.all, 5.0)
                        .border(/*@START_MENU_TOKEN@*/Color("AccentColor")/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
                        
                }
            }            
            
            .navigationTitle("Songs")
            .toolbar(content: {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button() {
                        writePlaylist()
                    } label: {
                        Label("Save Playlist", systemImage: "pianokeys").labelStyle(.titleAndIcon)
                    }
                }
                ToolbarItemGroup(content: {
                    HStack {
                        EditButton()
                        if (self.editMode?.wrappedValue == .active) {
                            Button() {
                                removeSelected()
                                
                            } label: {
                                Label("Remove from Playlist", systemImage: "trash")
                            }
                        }
                        if (self.editMode?.wrappedValue == .inactive) {
                            Button() {
                                handleGetRandomSongs()
                            } label: {
                                Label("Get Random", systemImage: "wand.and.stars").labelStyle(.titleAndIcon)
                            }
                        }
                        if (self.editMode?.wrappedValue == .active) {
                            Button() {
                                handleGetRandomSongs()
                            } label: {
                                Label("Get Random & Keep Selected", systemImage: "wand.and.stars").labelStyle(.titleAndIcon)
                            }
                        }
                    }
                })
            })
            
            .environment(\.editMode, editMode)
            
        }.navigationViewStyle(.stack)
        .onAppear(perform: {
            print("onAppear starting...")
            Task {
                await handleOnAppear()
            }
            print("onAppear exiting...")
        })
        
    }
    
    
    
    func move(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
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
            
            let populateThis = playlist!
            
            var mediaItems: [MPMediaItem] = []
            
            for track in items {
                mediaItems.append(track.mediaItem)
            }
            
            populateThis.add(mediaItems)
        }
        

    }
    
    private func removeSelected() {
        if (multiSelection.isEmpty == false) {
            for id in multiSelection {
                if let index = items.lastIndex(where: { $0.id == id })  {
                    items.remove(at: index)
                }
            }
            multiSelection = Set<UUID>()
        }
    }
    
    private func handleGetAllSongs() {
        
        print("getting all songs...")
        let query = MPMediaQuery.songs()
        let queryResults = query.items
        print("got all songs.")
        
        itemCount = queryResults?.count ?? -1
                
        var temp = Array<MediaItemWrapper>()

        if (queryResults != nil) {
            for item in queryResults! {
                temp.append(MediaItemWrapper(item: item))
            }
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
    
    private func handleOnAppear() async -> Void {
        if (isPreview == true) {
            return
        }
        
        print ("handleOnAppear() starting...")
        
        let returnValue = await requestMusicAuthorization()

        print ("handleOnAppear() starting...")
        
        if (returnValue == .authorized) {
            isAuthorizedForMusic = true
            handleGetRandomSongs()
        }
        
        print ("handleOnAppear() exiting...")
    }
    
    private func handleGetRandomSongs() {
        
        if (allItems == nil) {
            handleGetAllSongs()
        }
        
        let songCount = allItems!.count
        
        if (songCount == 0) {
            handleGetAllSongs()
        }
                
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
        
        /*
        switch musicAuthorizationStatus {
            case .notDetermined:
                Task {
                    print("requesting music auth status...")
                    musicAuthorizationStatus = await MusicAuthorization.request()
                    print("music auth status: \(musicAuthorizationStatus)...")
                    /*
                    let musicAuthorizationStatus = await MusicAuthorization.request()
                    await update(with: musicAuthorizationStatus)
                     */
                }
            case .denied:
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    openURL(settingsURL)
                }
            default:
                fatalError("No button should be displayed for current authorization status: \(musicAuthorizationStatus).")
        }
         */
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





struct Previews_SongsView_Previews: PreviewProvider {
    static var previews: some View {
        SongsView(musicAuthorizationStatus: .constant(.authorized), items: [ MediaItemWrapper(trackName: "track name 1", albumName: "album name 1", artistName: "artist name 1"),                                                                            MediaItemWrapper(trackName: "track name 2", albumName: "album name 2", artistName: "artist name 2"),                                                                            MediaItemWrapper(trackName: "track name 3", albumName: "album name 3", artistName: "artist name 3")])
            .environmentObject(PlaylistDataStore())
.previewInterfaceOrientation(.landscapeRight)
// .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro Max"))
.previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (5th generation)"))
.previewDisplayName("ipad authorized")
    }
    
    struct SongsView_Previews: PreviewProvider {
        
        static var previews: some View {
            SongsView(musicAuthorizationStatus: .constant(.notDetermined), items: [ MediaItemWrapper(trackName: "track name 1", albumName: "album name 1", artistName: "artist name 1"),                                                                            MediaItemWrapper(trackName: "track name 2", albumName: "album name 2", artistName: "artist name 2"),                                                                            MediaItemWrapper(trackName: "track name 3", albumName: "album name 3", artistName: "artist name 3")])
                .environmentObject(PlaylistDataStore())
    .previewInterfaceOrientation(.landscapeRight)
    // .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro Max"))
    .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (5th generation)"))
    .previewDisplayName("ipad not authorized")
        }
    }
    
    
    
}

public extension EnvironmentValues {
    var isPreview: Bool {
        #if DEBUG
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        #else
        return false
        #endif
    }
}
