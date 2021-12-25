//
//  PlaylistDetail.swift
//  PlaylistEditor (iOS)
//
//  Created by Benjamin Day on 12/25/21.
//

import SwiftUI
import MusicKit
import MediaPlayer

struct PlaylistDetail: View {
    
    let playlist: PlaylistItem
    
    var body: some View {
        NavigationView {
            VStack{
                Text("\(playlist.name)")
            }
            .navigationTitle("\(playlist.name)")
        }
        .onAppear(perform: populate)
            
    }
    
    func populate() {
        if (playlist.instance == nil) {
            print("playlist instance is null")
        }
        else if (playlist.instance?.items == nil) {
            print("playlist instnace items is null")
        }
        else {
            let songs = playlist.instance!.items
            for song in songs {
                let songTitle = song.value(forProperty: MPMediaItemPropertyTitle)
                print("\t\t", songTitle!)
            }
        }
    }
}

struct PlaylistDetail_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistDetail(playlist: PlaylistItem(name: "playlist title"))
    }
}
