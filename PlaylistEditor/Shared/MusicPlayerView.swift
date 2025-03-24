//
//  MusicPlayerView.swift
//  Random Playlist Generator (iOS)
//
//  Created by Benjamin Day on 3/24/25.
//

import SwiftUI
import MediaPlayer

struct MusicPlayerView: View {
    @StateObject private var musicPlayer = MusicPlayer()
    @State private var tracks: [MPMediaItem] = []

    var body: some View {
        VStack {
            Button("Select and Play Tracks") {
                let query = MPMediaQuery.songs()
                if let items = query.items {
                    tracks = items
                    musicPlayer.playTracks(items)
                }
            }

            Button(musicPlayer.isPlaying ? "Pause" : "Play") {
                musicPlayer.isPlaying ? musicPlayer.pause() : musicPlayer.playTracks(tracks)
            }
        }
    }
}

#Preview {
    MusicPlayerView()
}
