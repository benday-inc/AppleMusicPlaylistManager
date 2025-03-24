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
    @State var showPlaylistExistsAlert = false
    /// The current authorization status of MusicKit.
    @EnvironmentObject var storage: PlaylistDataStore
    
    @State var items: Array<MediaItemWrapper>
    @State var allItems: Array<MediaItemWrapper>?
    
    @State var itemCount: Int = -1
    @State private var multiSelection = Set<UUID>()
    @Environment(\.editMode) var editMode
    @Environment(\.isPreview) var isPreview
    
    var body: some View {
        
        NavigationView {
            VStack {
                
                List(selection: $multiSelection) {
                    ForEach (items) { item in
                        SongCell(item: item)
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                
                                Button("album", role: .destructive) {
                                    addAlbumExclusion(item: item)
                                }
                                Button("track", role: .destructive) {
                                    removeTrack(item: item)
                                }
                            }
                            .contextMenu() {
                                Button("Play Track") {
                                    withAnimation {
                                        playNow(item: item)
                                    }
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button("genre", role: .destructive) {
                                    addGenreExclusion(item: item)
                                }
                                Button("artist", role: .destructive) {
                                    addArtistExclusion(item: item)
                                }
                            }
                        
                    }
                    .onMove(perform: move)
                }
            }
            
            .navigationTitle("Songs")
            .toolbar(content: {
                ToolbarItemGroup(placement: .bottomBar) {
                    
                    Button() {
                        writePlaylist()
                    } label: {
                        Label("Save Playlist", systemImage: "square.and.arrow.down").labelStyle(.titleAndIcon)
                    }
                    .alert(isPresented: $showPlaylistExistsAlert) {
                        Alert(
                            title: Text("Yah...uhhh...about that..."),
                            message: Text("Can't overwrite an existing playlist. Delete the existing Random playlist first using the Music app"),
                            dismissButton: .default(Text("Uhhhgh. Seriously?"))
                        )
                    }
                    
                    Spacer()
                    Button() {
                        play()
                    } label: {
                        Label("Listen / Play", systemImage: "play.rectangle").labelStyle(.titleAndIcon)
                    }
                }
                
                ToolbarItemGroup(content: {
                    HStack {
                        EditButton()
                        Spacer()
                        Spacer()
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
            
        }
        .navigationViewStyle(.stack)
        .onAppear() {
            if (isPreview == false) {
                handleGetRandomSongs();
            }
        }
    }
    
    private func playNow(item: MediaItemWrapper) {
        let mediaItem = item.mediaItem
        
        let collection = MPMediaItemCollection(items: [mediaItem])
        
        let musicPlayer = MPMusicPlayerController.systemMusicPlayer
        
        musicPlayer.prepend(MPMusicPlayerMediaItemQueueDescriptor(itemCollection: collection))
        
        musicPlayer.skipToNextItem() // Play the new track now
    }
    
    private func play() {
        var mediaItems: [MPMediaItem] = []
        
        for track in items {
            mediaItems.append(track.mediaItem)
        }
        
        let musicPlayer = MPMusicPlayerController.systemMusicPlayer
        
        musicPlayer.setQueue(with: MPMediaItemCollection(items: mediaItems))
        
        musicPlayer.play()
    }
    
    private func removeExcluded(items: Array<MediaItemWrapper>) {
        var removeThese = Array<MediaItemWrapper>()
        
        for item in items {
            if (storage.isExcluded(item: item) == true) {
                removeThese.append(item)
            }
        }
        
        for item in removeThese {
            removeItem(item: item)
        }
    }
    
    private func removeItem(item: MediaItemWrapper) {
        let removeAtIndex = items.firstIndex(where: { $0.id == item.id })
        
        if (removeAtIndex != nil) {
            self.items.remove(at: removeAtIndex!)
        }
    }
    
    private func addAlbumExclusion(item: MediaItemWrapper) {
        storage.addAlbumExclusion(item: item)
        removeExcluded(items: self.items)
    }
    
    private func addGenreExclusion(item: MediaItemWrapper) {
        storage.addGenreExclusion(item: item)
        removeExcluded(items: self.items)
    }
    
    private func addArtistExclusion(item: MediaItemWrapper) {
        storage.addArtistExclusion(item: item)
        removeExcluded(items: self.items)
    }
    
    private func removeTrack(item: MediaItemWrapper) {
        removeItem(item: item)
    }
    
    func move(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }
    
    private func getPlaylistByName(playlistName: String) -> MPMediaPlaylist? {
        let myPlaylistQuery = MPMediaQuery.playlists()
        
        var returnValue: MPMediaPlaylist? = nil
        let pred = MPMediaPropertyPredicate(value: playlistName,
                                            forProperty: MPMediaPlaylistPropertyName)
        
        myPlaylistQuery.addFilterPredicate(pred)
        
        returnValue = myPlaylistQuery.collections?.first as? MPMediaPlaylist
        
        //        for case let playlist as MPMediaPlaylist in playlists! {
        //
        //            temp.append(PlaylistItem(name: playlist.name!, instance: playlist))
        //        }
        
        return returnValue
    }
    
    private func writePlaylistForDate() {
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
    
    private func createNewPlaylist(playlistName: String) {
        let metadata = MPMediaPlaylistCreationMetadata(name: playlistName)
        
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
    
    
    
    private func writePlaylist() {
        let name = "Random"
        
        let playlist = getPlaylistByName(playlistName: name)
        
        if (playlist == nil) {
            print("playlist doesn't exist...creating new")
            createNewPlaylist(playlistName: name)
        }
        else {
            print("playlist doesn't exist...creating new")
            
            showPlaylistExistsAlert = true
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
    
    private func handleGetRandomSongs() {
        
        if (allItems == nil) {
            handleGetAllSongs()
        }
        
        let songCount = allItems!.count
        
        if (songCount == 0) {
            handleGetAllSongs()
        }
        
        let randomIndexes = getRandomIndexes(maxIndex: songCount, numberOfValuesToReturn: 100)
        
        var newPlaylistItems = Array<MediaItemWrapper>()
        
        // copy pinned items to new playlist
        if (multiSelection.isEmpty == false) {
            for id in multiSelection {
                if let index = items.lastIndex(where: { $0.id == id })  {
                    newPlaylistItems.append(items[index])
                }
            }
            multiSelection = Set<UUID>()
        }
        
        // create random playlist
        for index in randomIndexes {
            let tempSong = allItems![index]
            
            if (storage.isExcluded(item: tempSong) == false) {
                newPlaylistItems.append(tempSong)
                print("not excluded")
            }
            else {
                print("excluded")
            }
        }
        
        // set new array to items for binding to UI
        items = newPlaylistItems
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


#Preview {
    SongsView(items: [
        MediaItemWrapper(trackName: "track name 1", albumName: "album name 1", artistName: "artist name 1"),
        MediaItemWrapper(trackName: "track name 2", albumName: "album name 2", artistName: "artist name 2"),
        MediaItemWrapper(trackName: "track name 3", albumName: "album name 3", artistName: "artist name 3")])
    .environmentObject(PlaylistDataStore())
}


