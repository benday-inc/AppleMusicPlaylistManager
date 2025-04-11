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
    @State var playlistMode: String = "Mode: All"
    
    @State var itemCount: Int = -1
    @State private var multiSelection = Set<UUID>()
    @Environment(\.editMode) var editMode
    @Environment(\.isPreview) var isPreview
    
    @State var isFirstShowOfForm = true
    
    @State var currentArtist: String = ""
    @State var currentGenre: String = ""
    
    var body: some View {
        
        NavigationView {
            VStack {
                
                List(selection: $multiSelection) {
                    ForEach (items) { item in
                        SongCell(item: item)
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                
                                
                                Button("track", systemImage: "trash", role: .destructive) {
                                    removeTrack(item: item)
                                }
                                .tint(.red)
                                
                                Button("album") {
                                    addAlbumExclusion(item: item)
                                }
                                .tint(.secondary)
                            }
                            .contextMenu() {
                                Button("Play Track") {
                                    withAnimation {
                                        playNow(item: item)
                                    }
                                }
                                Button("Randomize Artist") {
                                    withAnimation {
                                        randomizeArtist(item: item)
                                    }
                                }
                                Button("Randomize Genre") {
                                    withAnimation {
                                        randomizeGenre(item: item)
                                    }
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button("genre") {
                                    addGenreExclusion(item: item)
                                }
                                .tint(.secondary)
                                Button("artist") {
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
                
                ToolbarItemGroup(placement: .topBarLeading, content: {
                    HStack {
                        Button() {
                            changePlaylistMode()
                        } label: {
                            Text(playlistMode)
                        }
                    }
                } )
                
                ToolbarItemGroup(placement: .topBarTrailing, content: {
                    HStack {
                        EditButton()
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
                } )
            })
            .environment(\.editMode, editMode)
            
        }
        .navigationViewStyle(.stack)
        .onAppear() {
            if (isFirstShowOfForm == true) {
                isFirstShowOfForm = false;
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
    
    private func randomizeGenre(item: MediaItemWrapper) {
        let genre = item.genreName
        
        if (genre == "") {
            return
        }
        else {
            currentGenre = genre
            currentArtist = ""
            playlistMode = AppConstants.PLAYLIST_MODE_RANDOMIZE_GENRE
            
            allItems = nil
            items = Array<MediaItemWrapper>()
            handleGetRandomSongs()
        }
    }
    
    private func randomizeArtist(item: MediaItemWrapper) {
        let artist = item.artistName
        
        if (artist == "") {
            return
        }
        else {
            currentGenre = ""
            currentArtist = artist
            playlistMode = AppConstants.PLAYLIST_MODE_RANDOMIZE_ARTIST
            
            allItems = nil
            items = Array<MediaItemWrapper>()
            handleGetRandomSongs()
        }
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
            if (storage.isExcluded(item: item, playlistMode: playlistMode) == true) {
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
        
        let query: MPMediaQuery
        
        if (playlistMode == AppConstants.PLAYLIST_MODE_ALL) {
            query = MPMediaQuery.songs()
        }
        else if (playlistMode == AppConstants.PLAYLIST_MODE_HENDRIE) {
            query = MPMediaQuery.songs()
            let predicate = MPMediaPropertyPredicate(
                value: "Phil Hendrie",
                forProperty: MPMediaItemPropertyArtist,
                comparisonType: .contains
            )
            query.addFilterPredicate(predicate)
        }
        else if (playlistMode == AppConstants.PLAYLIST_MODE_SPYRO_GYRA) {
            query = MPMediaQuery.songs()
            let predicate = MPMediaPropertyPredicate(
                value: "Spyro Gyra",
                forProperty: MPMediaItemPropertyArtist,
                comparisonType: .contains
            )
            query.addFilterPredicate(predicate)
        }
        else if (playlistMode == AppConstants.PLAYLIST_MODE_RIPPINGTONS) {
            query = MPMediaQuery.songs()
            let predicate = MPMediaPropertyPredicate(
                value: "Rippingtons",
                forProperty: MPMediaItemPropertyArtist,
                comparisonType: .contains
            )
            query.addFilterPredicate(predicate)
        }
        else if (playlistMode == AppConstants.PLAYLIST_MODE_YELLOWJACKETS) {
            query = MPMediaQuery.songs()
            let predicate = MPMediaPropertyPredicate(
                value: "Yellowjackets",
                forProperty: MPMediaItemPropertyArtist,
                comparisonType: .contains
            )
            query.addFilterPredicate(predicate)
        }
        else if (playlistMode == AppConstants.PLAYLIST_MODE_CHICK_COREA) {
            query = MPMediaQuery.songs()
            let predicate = MPMediaPropertyPredicate(
                value: "Chick Corea",
                forProperty: MPMediaItemPropertyArtist,
                comparisonType: .contains
            )
            query.addFilterPredicate(predicate)
        }
        else if (playlistMode == AppConstants.PLAYLIST_MODE_RANDOMIZE_ARTIST) {
            query = MPMediaQuery.songs()
            let predicate = MPMediaPropertyPredicate(
                value: currentArtist,
                forProperty: MPMediaItemPropertyArtist,
                comparisonType: .contains
            )
            query.addFilterPredicate(predicate)
        }
        else if (playlistMode == AppConstants.PLAYLIST_MODE_RANDOMIZE_GENRE) {
            query = MPMediaQuery.songs()
            let predicate = MPMediaPropertyPredicate(
                value: currentGenre,
                forProperty: MPMediaItemPropertyGenre,
                comparisonType: .equalTo
            )
            query.addFilterPredicate(predicate)
        }
        else {
            let genre = playlistMode.replacingOccurrences(of: "Mode: ", with: "")
            
            query = MPMediaQuery.songs()
            let predicate = MPMediaPropertyPredicate(
                value: genre,
                forProperty: MPMediaItemPropertyGenre,
                comparisonType: .equalTo
            )
            query.addFilterPredicate(predicate)
        }
        
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
    
    private func changePlaylistMode() {
        let modes: [String] = [
            AppConstants.PLAYLIST_MODE_ALL,
            AppConstants.PLAYLIST_MODE_JAZZ,
            AppConstants.PLAYLIST_MODE_CLASSICAL,
            AppConstants.PLAYLIST_MODE_YELLOWJACKETS,
            AppConstants.PLAYLIST_MODE_CHICK_COREA,
            AppConstants.PLAYLIST_MODE_RIPPINGTONS,
            AppConstants.PLAYLIST_MODE_SPYRO_GYRA,
            AppConstants.PLAYLIST_MODE_HENDRIE
        ]
        
        let selectedIndex = modes.firstIndex(of: playlistMode)
        
        if (selectedIndex == nil) {
            playlistMode = modes[0]
        }
        else {
            if (selectedIndex! == modes.count - 1) {
                playlistMode = modes[0]
            }
            else {
                playlistMode = modes[selectedIndex! + 1]
            }
        }
        
        allItems = nil
        items = Array<MediaItemWrapper>()
        handleGetRandomSongs()
    }
    
    private func handleGetRandomSongs() {
        if (isPreview == true) {
            return
        }
        
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
            
            if (storage.isExcluded(item: tempSong, playlistMode: playlistMode) == false) {
                newPlaylistItems.append(tempSong)
                // print("not excluded")
            }
            else {
                // print("excluded")
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
        MediaItemWrapper(trackName: "track name 1", albumName: "album name 1", artistName: "artist name 1", genreName: "genre 1"),
        MediaItemWrapper(trackName: "track name 2", albumName: "album name 2", artistName: "artist name 2", genreName: "genre 1"),
        MediaItemWrapper(trackName: "track name 3", albumName: "album name 3", artistName: "artist name 3", genreName: "genre 1")])
    .environmentObject(PlaylistDataStore())
}


