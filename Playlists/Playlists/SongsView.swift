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
    @State var showPlaylistExistsAlert = false
    
    @Environment(\.editMode) var editMode
    
    @State var isFirstShowOfForm = true
    @State var isPlaylistSheetVisible = false
    
    @EnvironmentObject private var storage: PlaylistDataStore
    @StateObject private var viewModel: SongsViewModel
    
    @State var autoPlay = false
    
    init(_ storage: PlaylistDataStore) {
        print("SongsView init")
        _viewModel = StateObject(wrappedValue: SongsViewModel(storage: storage))
    }
    
    init(testItems: [MediaItemWrapper]) {
        print("SongsView init using test data")
        let dummyStore = PlaylistDataStore(testDataExcludedGenres: [], testDataExcludedArtists: [], testDataExcludedAlbums: [])
        _viewModel = StateObject(wrappedValue: SongsViewModel(testItems: testItems, storage: dummyStore))
    }
    
    init(category: Category, storage: PlaylistDataStore) {
        print("SongsView init with category")
        autoPlay = true
        _viewModel = StateObject(wrappedValue: SongsViewModel(category: category, storage: storage))
        
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List(selection: $viewModel.multiSelection) {
                    ForEach (viewModel.items) { item in
                        SongCell(item: item)
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button("Remove Track", systemImage: "minus.circle.fill", role: .destructive) {
                                    viewModel.removeTrack(item: item)
                                }
                                .tint(.red)
                                
                                Button("Exclude Album", systemImage: "opticaldisc") {
                                    viewModel.addAlbumExclusion(item: item)
                                }
                                .tint(.secondary)
                            }
                            .contextMenu() {
                                Button("Play Track", systemImage: "play.fill") {
                                    withAnimation {
                                        viewModel.playNow(item: item)
                                    }
                                }
                                Divider()
                                Button("Randomize Artist and Play", systemImage: "person.2.crop.square.stack") {
                                    withAnimation {
                                        viewModel.randomizeArtist(item: item)
                                        viewModel.play()
                                    }
                                }
                                Button("Randomize Genre and Play", systemImage: "music.note.tv") {
                                    withAnimation {
                                        viewModel.randomizeGenre(item: item)
                                        viewModel.play()
                                    }
                                }
                                Divider()
                                Button("Randomize Artist", systemImage: "person.crop.circle.dashed") {
                                    withAnimation {
                                        viewModel.randomizeArtist(item: item)
                                    }
                                }
                                Button("Randomize Genre", systemImage: "guitars") {
                                    withAnimation {
                                        viewModel.randomizeGenre(item: item)
                                    }
                                }
                                Divider()
                                Button("Play Album", systemImage: "opticaldisc") {
                                    withAnimation {
                                        viewModel.playAlbum(item: item)
                                    }
                                }
                                Divider()
                                Button("Exclude Genre", systemImage: "guitars.fill") {
                                    print("Item count: \(viewModel.items.count) before withAnimation")
                                    withAnimation {
                                        viewModel.addGenreExclusion(item: item)
                                        print("Item count: \(viewModel.items.count) inside withAnimation")
                                    }
                                    print("Item count: \(viewModel.items.count) after withAnimation")
                                }
                                Button("Exclude Artist", systemImage: "person.crop.circle.badge.minus") {
                                    withAnimation {
                                        viewModel.addArtistExclusion(item: item)
                                    }
                                }
                                Button("Exclude Album", systemImage: "opticaldisc.fill") {
                                    withAnimation {
                                        viewModel.addAlbumExclusion(item: item)
                                    }
                                }
                                Button("Remove Track", systemImage: "minus.circle.fill", role: .destructive) {
                                    withAnimation {
                                        viewModel.removeTrack(item: item)
                                    }
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button("Exclude Genre", systemImage: "guitars") {
                                    viewModel.addGenreExclusion(item: item)
                                }
                                .tint(.secondary)
                                Button("Exclude Artist", systemImage: "person.crop.circle") {
                                    viewModel.addArtistExclusion(item: item)
                                }
                                .tint(.secondary)
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
            .navigationTitle("Playlist Builder")
            .toolbar(id: "main-toolbar") {
                // Bottom toolbar items with IDs for customizable toolbar
                ToolbarItem(id: "save", placement: .bottomBar) {
                    Button {
                        isPlaylistSheetVisible.toggle()
                    } label: {
                        Label("Save", systemImage: "plus.square.on.square")
                    }
                }
                
                ToolbarItem(id: "track-count", placement: .bottomBar) {
                    HStack(spacing: 4) {
                        Image(systemName: "music.note.list")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        Text("\(viewModel.items.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                ToolbarItem(id: "play", placement: .bottomBar) {
                    Button {
                        viewModel.play()
                    } label: {
                        Label("Play", systemImage: "play.fill")
                    }
                }
                
                // Leading navigation item
                ToolbarItem(id: "playlist-mode", placement: .topBarLeading) {
                    Button {
                        viewModel.changePlaylistMode()
                    } label: {
                        Text(viewModel.playlistMode)
                    }
                }
                
                // Trailing navigation items
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
            if (autoPlay == true) {
                viewModel.play()
            }
            else if (isFirstShowOfForm == true) {
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
