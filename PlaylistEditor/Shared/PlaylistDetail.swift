//
//  PlaylistDetail.swift
//  RandomPlaylistGenerator (iOS)
//
//  Created by Benjamin Day on 12/25/21.
//

import SwiftUI
import MusicKit
import MediaPlayer

struct PlaylistDetail: View {
    
    let playlist: PlaylistItem
    @State var songs: Array<MediaItemWrapper> = Array<MediaItemWrapper>()
    @State var songCount: Int = 0
    
    var body: some View {
        NavigationView {
            List {
                if (songs.count == 0) {
                    Text("no items")
                }
                else {
                    ForEach(songs) { item in
                        Text("\(item.trackName)").allowsTightening(true)
                    }
                }
            }
            Text("Count: \(songCount)")
        }.navigationTitle("\(playlist.name)")
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
            let playlistInstance = playlist.instance!
            songCount = playlistInstance.count
            let tempSongs = playlistInstance.items
            for song in tempSongs {
                // let songTitle = song.value(forProperty: MPMediaItemPropertyTitle) 
                // print("\t\t", songTitle!)
                temp.append(MediaItemWrapper(item: song))
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
