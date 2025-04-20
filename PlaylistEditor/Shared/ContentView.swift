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
    @State var musicAuthorizationStatus: MusicAuthorization.Status
    
    var body: some View {
        MusicLibraryAuthorizationView(authorizationStatus: $musicAuthorizationStatus)
        
        if (musicAuthorizationStatus == .authorized)         {
            if (storage.isLoaded == false) {
                Text("Loading...")
            }
            else {
                TabView {
                    SongsView()
                        .environmentObject(storage)
                        .environmentObject(SongsViewModel(storage: storage))
                        .tabItem {
                            Label("Songs", systemImage: "square.and.pencil")
                        }.tag(0)
                    ExclusionsView()
                        .environmentObject(storage)
                        .tabItem {
                            Label("Exclusions", systemImage: "slider.horizontal.3")
                        }.tag(1)
                    PlaylistsView(_playlists: [])
                        .tabItem {
                            Label("Playlists", systemImage: "music.note.list")
                        }.tag(2)
                }
            }
        }
    }
    
    private func handleOnAppear() async -> Void {
        print ("handleOnAppear() starting...")
        
        let returnValue = await requestMusicAuthorization()
        
        musicAuthorizationStatus = returnValue
        
        print ("handleOnAppear() exiting...")
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



