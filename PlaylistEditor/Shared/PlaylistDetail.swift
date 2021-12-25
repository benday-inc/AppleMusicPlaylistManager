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
    @State var songs: Array<MediaItemWrapper> = Array<MediaItemWrapper>()
    
    var body: some View {
        NavigationView {
//            VStack{
//                Text("\(playlist.name)")
//            }
            
            List {
                if (songs.count == 0) {
                    Text("no items")
                }
                else {
                    ForEach(songs) { item in
                        
                        Text("\(item.trackName)")
                        
                    }
                }
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
            print("playlist instance items is null")
        }
        else {
            var temp = Array<MediaItemWrapper>()
            let tempSongs = playlist.instance!.items
            for song in tempSongs {
                let songTitle = song.value(forProperty: MPMediaItemPropertyTitle) 
                // print("\t\t", songTitle!)
                temp.append(MediaItemWrapper(instance: song))
            }
            
            songs = temp
        }
    }
}

struct PlaylistDetail_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistDetail(playlist: PlaylistItem(name: "playlist title"))
    }
}
