//
//  MediaItemWrapper.swift
//  PlaylistEditor (iOS)
//
//  Created by Benjamin Day on 12/26/21.
//

import Foundation
import MusicKit
import MediaPlayer

struct MediaItemWrapper: Identifiable, Hashable {
    var id = UUID()
    private var _instance: MPMediaItem?
    private var _readFromItem: Bool
    private var _trackName: String
    private var _artistName: String
    private var _albumName: String
    
    init(trackName: String,
         albumName: String,
         artistName: String) {
        _trackName = trackName
        _artistName = artistName
        _albumName = albumName
        _readFromItem = false
        _instance = nil
    }
    
    init(item: MPMediaItem) {
        _instance = item
        _readFromItem = true
        _trackName = ""
        _artistName = ""
        _albumName = ""
    }
    
    var trackName: String {
        get {
            if (_readFromItem == false) {
                return _trackName
            }
            else {
                let temp = _instance!.value(forProperty: MPMediaItemPropertyTitle) as! String
                
                return temp
            }
        }
    }
    
    var albumName: String {
        get {
            if (_readFromItem == false) {
                return _albumName
            }
            else {
                let temp = _instance!.value(forProperty: MPMediaItemPropertyAlbumTitle) as! String
                
                return temp
            }
        }
    }
    
    var artistName: String {
        get {
            if (_readFromItem == false) {
                return _artistName
            }
            else {
                let temp = _instance!.value(forProperty: MPMediaItemPropertyArtist) as! String
            
                return temp
            }
        }
    }
    
    var genreName: String {
        get {
            if (_readFromItem == false) {
                return "genre 123"
            }
            else {
                let temp = _instance!.value(forProperty: MPMediaItemPropertyGenre) as! String
            
                return temp
            }
        }
    }
}
