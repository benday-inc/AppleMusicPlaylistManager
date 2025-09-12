//
//  SongsView.swift
//  RandomPlaylistGenerator (iOS)
//
//  Created by Benjamin Day on 12/26/21.
//

import SwiftUI
import MusicKit
import MediaPlayer
import os.log

struct SongsView: View {
    private let logger = Logger(subsystem: "com.randomplaylistgenerator", category: "SongsView")
    
    @State var showPlaylistExistsAlert = false
    
    @Environment(\.editMode) var editMode
    
    @State var isFirstShowOfForm = true
    @State var isPlaylistSheetVisible = false
    
    
    @State var title: String
    
    
    
    @EnvironmentObject private var storage: PlaylistDataStore
    @StateObject private var viewModel: SongsViewModel
    
    @State var autoPlay = false
    
    init(_ storage: PlaylistDataStore) {
        logger.info("SongsView init started")
        _viewModel = StateObject(wrappedValue: SongsViewModel(storage: storage))
        title = "Playlist Builder"
        logger.info("SongsView init completed")
    }
    
    init(testItems: [MediaItemWrapper]) {
        logger.info("SongsView test init started")
        let dummyStore = PlaylistDataStore(testDataExcludedGenres: [], testDataExcludedArtists: [], testDataExcludedAlbums: [])
        _viewModel = StateObject(wrappedValue: SongsViewModel(testItems: testItems, storage: dummyStore))
        title = "Test Data"
        logger.info("SongsView test init completed")
    }
    
    init(category: Category, storage: PlaylistDataStore) {
        logger.info("SongsView category init started for: \(category.name)")
        autoPlay = true
        _viewModel = StateObject(wrappedValue: SongsViewModel(category: category, storage: storage))
        title = category.name
        logger.info("SongsView category init completed")
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List(selection: $viewModel.multiSelection) {
                    ForEach (viewModel.items) { item in
                        SongCell(item: item)
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                
                                
                                Button("track", systemImage: "trash", role: .destructive) {
                                    viewModel.removeTrack(item: item)
                                }
                                .tint(.red)
                                
                                Button("album") {
                                    viewModel.addAlbumExclusion(item: item)
                                }
                                .tint(.secondary)
                            }
                            .contextMenu() {
                                Button("Play Track") {
                                    withAnimation {
                                        viewModel.playNow(item: item)
                                    }
                                }
                                Divider()
                                Button("Randomize Artist and Play") {
                                    withAnimation {
                                        viewModel.randomizeArtist(item: item)
                                        viewModel.play()
                                    }
                                }
                                Button("Randomize Genre and Play") {
                                    withAnimation {
                                        viewModel.randomizeGenre(item: item)
                                        viewModel.play()
                                    }
                                }
                                Divider()
                                Button("Randomize Artist") {
                                    withAnimation {
                                        viewModel.randomizeArtist(item: item)
                                    }
                                }
                                Button("Randomize Genre") {
                                    withAnimation {
                                        viewModel.randomizeGenre(item: item)
                                    }
                                }
                                Divider()
                                Button("Play Album") {
                                    withAnimation {
                                        viewModel.playAlbum(item: item)
                                    }
                                }
                                Divider()
                                Button("Exclude Genre") {
                                    print("Item count: \(viewModel.items.count) before withAnimation")
                                    withAnimation {
                                        viewModel.addGenreExclusion(item: item)
                                        print("Item count: \(viewModel.items.count) inside withAnimation")
                                    }
                                    print("Item count: \(viewModel.items.count) after withAnimation")
                                }
                                Button("Exclude Artist") {
                                    withAnimation {
                                        viewModel.addArtistExclusion(item: item)
                                    }
                                }
                                Button("Exclude Album") {
                                    withAnimation {
                                        viewModel.addAlbumExclusion(item: item)
                                    }
                                }
                                Button("Remove Track", systemImage: "trash", role: .destructive) {
                                    withAnimation {
                                        viewModel.removeTrack(item: item)
                                    }
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button("genre") {
                                    viewModel.addGenreExclusion(item: item)
                                }
                                .tint(.secondary)
                                Button("artist") {
                                    viewModel.addArtistExclusion(item: item)
                                }
                            }
                        
                    }
                    .onMove(perform: viewModel.move)
                }
            }
            .sheet(isPresented: $isPlaylistSheetVisible, content: {
                PlaylistNameSheetView() { doSave, playlistName in
                    if (doSave == true) {
                        createNewPlaylist(playlistName: playlistName)
                    }
                    
                    isPlaylistSheetVisible = false
                }
            })
            .navigationTitle(title)
            .toolbar(id: "main-toolbar") {
//                // Leading navigation items
//                ToolbarItem(id: "playlist-mode", placement: .topBarLeading) {
//                    Button {
//                        viewModel.changePlaylistMode()
//                    } label: {
//                        Text(viewModel.playlistMode)
//                    }
//                }
                
                // Principal item for track count (appears in center when space allows)
                ToolbarItem(id: "track-count", placement: .principal) {
                    HStack(spacing: 4) {
                        Image(systemName: "music.note.list")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        Text("\(viewModel.items.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Trailing navigation items - moved from bottom to top
                ToolbarItem(id: "save", placement: .topBarTrailing) {
                    Button {
                        isPlaylistSheetVisible.toggle()
                    } label: {
                        Label("Save", systemImage: "plus.square.on.square")
                    }
                }
                
                ToolbarItem(id: "play", placement: .topBarTrailing) {
                    Button {
                        viewModel.play()
                    } label: {
                        Label("Play", systemImage: "play.fill")
                    }
                }
                
                ToolbarItem(id: "edit", placement: .topBarTrailing) {
                    EditButton()
                }
                
                if editMode?.wrappedValue == .active {
                    ToolbarItem(id: "remove-selected", placement: .topBarTrailing) {
                        Button {
                            viewModel.removeSelected()
                        } label: {
                            Label("Remove from Playlist", systemImage: "minus.circle")
                        }
                    }
                    
                    ToolbarItem(id: "random-keep", placement: .topBarTrailing) {
                        Button {
                            viewModel.handleGetRandomSongs()
                        } label: {
                            Label("Get Random & Keep Selected", systemImage: "shuffle.circle")
                        }
                    }
                } else {
                    ToolbarItem(id: "random", placement: .topBarTrailing) {
                        Button {
                            viewModel.handleGetRandomSongs()
                        } label: {
                            Label("Get Random", systemImage: "shuffle")
                        }
                    }
                }
            }
            .environment(\.editMode, editMode)
            
        }
        .navigationViewStyle(.stack)
        .onAppear() {
            logger.info("SongsView appeared")
            if (autoPlay == true) {
                logger.info("Auto-playing")
                viewModel.play()
            }
            else if (isFirstShowOfForm == true) {
                logger.info("First show - getting random songs")
                isFirstShowOfForm = false;
                viewModel.handleGetRandomSongs();
            }
        }
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
    
    private func createNewPlaylist(playlistName: String) {
        let trimmed = playlistName.trimmingCharacters(in: .whitespaces)
        
        let metadata = MPMediaPlaylistCreationMetadata(name: trimmed)
        let playlistUUID = UUID()
        
        MPMediaLibrary.default().getPlaylist(with: playlistUUID, creationMetadata: metadata) { playlist, error in
            guard let playlist = playlist, error == nil else {
                print("Error creating playlist: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            
            let mediaItems = viewModel.items.compactMap { $0.mediaItem }
            
            playlist.add(mediaItems) { addError in
                if let addError = addError {
                    print("Failed to add items: \(addError.localizedDescription)")
                } else {
                    print("Successfully added \(mediaItems.count) tracks to \(playlistName)")
                }
            }
            
        }
    }
    
}


#Preview {
    
    let items = [
        MediaItemWrapper(trackName: "track name 1", artistName: "artist name 1", albumName: "album name 1", genreName: "genre 1"),
        MediaItemWrapper(trackName: "track name 2", artistName: "artist name 2", albumName: "album name 2", genreName: "genre 1"),
        MediaItemWrapper(trackName: "track name 3", artistName: "artist name 3", albumName: "album name 3", genreName: "genre 1")]
    
    let playlistDataStore = PlaylistDataStore(
        testDataExcludedGenres: [], testDataExcludedArtists: [], testDataExcludedAlbums: [])
    
    // let viewModel = SongsViewModel(testItems: items, storage: playlistDataStore)
    
    SongsView(testItems: items)
        .environmentObject(playlistDataStore)
}
