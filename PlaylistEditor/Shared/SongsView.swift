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
    @EnvironmentObject var viewModel: SongsViewModel
    
    @State var showPlaylistExistsAlert = false
    
    @Environment(\.editMode) var editMode
    
    @State var isFirstShowOfForm = true
    @State var isPlaylistSheetVisible = false
    
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
            .sheet(isPresented: $isPlaylistSheetVisible, content: {
                PlaylistNameSheetView() { doSave, playlistName in
                    if (doSave == true) {
                        createNewPlaylist(playlistName: playlistName)
                    }
                    
                    isPlaylistSheetVisible = false
                }
            })
            
            .navigationTitle("Playlist Builder")
            .toolbar(content: {
                ToolbarItemGroup(placement: .bottomBar) {
                    
                    Button() {
                        isPlaylistSheetVisible.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Save")
                        }
#if(ios)
.padding(.bottom)
#endif
                    }
                    
                    Spacer()
                    Button() {
                        viewModel.play()
                    } label: {
                        HStack {
                            Text("Play")
                            Image(systemName: "play.rectangle")
                        }
#if(ios)
.padding(.bottom)
#endif
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
    
    let playlistDataStore = PlaylistDataStore()
    
    let viewModel = SongsViewModel(testItems: items, storage: playlistDataStore)
    
    SongsView()
        .environmentObject(PlaylistDataStore())
        .environmentObject(viewModel)
}


