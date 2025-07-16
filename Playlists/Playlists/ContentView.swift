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
    @StateObject private var storage = PlaylistDataStore()
    @StateObject private var categoryListVM = CategoryListViewModel()
    @State var musicAuthorizationStatus: MusicAuthorization.Status
    
    var body: some View {
        MusicLibraryAuthorizationView(authorizationStatus: $musicAuthorizationStatus)
        
        if (musicAuthorizationStatus == .authorized)         {
            if (storage.isLoaded == false) {
                Text("Loading...")
            }
            else {
                TabView {
                    CategoryListView()
                        .environmentObject(categoryListVM)
                        .tabItem {
                            Label("Categories", systemImage: "list.bullet")
                        }.tag(0)
                        .onAppear() {
                            if (categoryListVM.isLoaded == false) {
                                categoryListVM.load(from: [])
                                
                                // subscribe to save events
                                categoryListVM.didSave.sink { categories in
                                    self.saveCategories(categories: categories)
                                }.store(in: &categoryListVM.anyCancellable)
                            }
                        }
                    
                    SongsView()
                        .environmentObject(storage)
                        .environmentObject(SongsViewModel(storage: storage))
                        .tabItem {
                            Label("Build Playlist", systemImage: "square.and.pencil")
                        }.tag(1)
                    ExclusionsView()
                        .environmentObject(storage)
                        .tabItem {
                            Label("Playlist Exclusions", systemImage: "slider.horizontal.3")
                        }.tag(2)
//                    PlaylistsView(_playlists: [])
//                        .tabItem {
//                            Label("Playlists", systemImage: "music.note.list")
//                        }.tag(2)
                    AboutView()
                        .tabItem {
                            Label("About", systemImage: "info.bubble")
                        }.tag(3)
                    
                }
            }
        }
    }

    func saveCategories(categories: [Category]) {
        print("ContentView: Saving categories...")
        self.storage.categories = categories
        self.storage.save()
        print("ContentView: Categories saved.")
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
    }
}

#Preview {
    ContentView(musicAuthorizationStatus: .authorized)
}



