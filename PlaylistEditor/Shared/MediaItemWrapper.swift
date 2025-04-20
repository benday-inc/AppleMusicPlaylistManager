//
//  MediaItemWrapper.swift
//  RandomPlaylistGenerator (iOS)
//
//  Created by Benjamin Day on 12/26/21.
//

import Foundation
import MusicKit
import MediaPlayer

class MediaItemWrapper: Identifiable, ObservableObject {
    var id = UUID()
    
    @Published var trackName: String = ""
    @Published var artistName: String = ""
    @Published var albumName: String = ""
    @Published var genreName: String = ""
    private var _instance: MPMediaItem?
    
    init(trackName: String, artistName: String, albumName: String, genreName: String) {
        self.trackName = trackName
        self.artistName = artistName
        self.albumName = albumName
        self.genreName = genreName
        _instance = nil
    }
    
    init(item: MPMediaItem) {
        _instance = item
        self.trackName = item.value(forProperty: MPMediaItemPropertyTitle) as? String ?? ""
        self.artistName = item.value(forProperty: MPMediaItemPropertyArtist) as? String ?? ""
        self.albumName = item.value(forProperty: MPMediaItemPropertyAlbumTitle) as? String ?? ""
        self.genreName = item.value(forProperty: MPMediaItemPropertyGenre) as? String ?? ""
    }
    
    var mediaItem: MPMediaItem? {
        get {
            return _instance
        }
    }
}
