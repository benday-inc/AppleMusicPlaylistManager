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
    @EnvironmentObject var viewModel: SongsViewModel
    
    @State var doSomethingText = "(not set)"
    @State var showPlaylistExistsAlert = false
    // @EnvironmentObject var storage: PlaylistDataStore
    
//    @State var items: Array<MediaItemWrapper>
//    @State var allItems: Array<MediaItemWrapper>?
    
    @State var itemCount: Int = -1

    @Environment(\.editMode) var editMode
    @Environment(\.isPreview) var isPreview
    
    @State var isFirstShowOfForm = true
    

    
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
                        viewModel.play()
                    } label: {
                        Label("Listen / Play", systemImage: "play.rectangle").labelStyle(.titleAndIcon)
                    }
                }
                
                ToolbarItemGroup(placement: .topBarLeading, content: {
                    HStack {
                        Button() {
                            viewModel.changePlaylistMode()
                        } label: {
                            Text(viewModel.playlistMode)
                        }
                    }
                } )
                
                ToolbarItemGroup(placement: .topBarTrailing, content: {
                    HStack {
                        EditButton()
                        Spacer()
                        if (self.editMode?.wrappedValue == .active) {
                            Button() {
                                viewModel.removeSelected()
                                
                            } label: {
                                Label("Remove from Playlist", systemImage: "trash")
                            }
                        }
                        if (self.editMode?.wrappedValue == .inactive) {
                            Button() {
                                viewModel.handleGetRandomSongs()
                            } label: {
                                Label("Get Random", systemImage: "wand.and.stars").labelStyle(.titleAndIcon)
                            }
                        }
                        if (self.editMode?.wrappedValue == .active) {
                            Button() {
                                viewModel.handleGetRandomSongs()
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
            
            for track in viewModel.items {
                if track.mediaItem != nil {
                    mediaItems.append(track.mediaItem!)
                }
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
            
            for track in viewModel.items {
                if track.mediaItem != nil {
                    mediaItems.append(track.mediaItem!)
                }
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
}


#Preview {

    let items = [
        MediaItemWrapper(trackName: "track name 1", artistName: "artist name 1", albumName: "album name 1", genreName: "genre 1"),
        MediaItemWrapper(trackName: "track name 2", artistName: "artist name 2", albumName: "album name 2", genreName: "genre 1"),
        MediaItemWrapper(trackName: "track name 3", artistName: "artist name 3", albumName: "album name 3", genreName: "genre 1")]
    
    let playlistDataStore = PlaylistDataStore()
    
    let viewModel = SongsViewModel(testItems: items, storage: playlistDataStore)
    
    SongsView()
        .environmentObject(PlaylistDataStore())
        .environmentObject(viewModel)
}


