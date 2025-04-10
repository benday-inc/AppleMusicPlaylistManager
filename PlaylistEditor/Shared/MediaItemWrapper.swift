//
//  MediaItemWrapper.swift
//  RandomPlaylistGenerator (iOS)
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
    private var _genreName: String
    
    init(trackName: String,
         albumName: String,
         artistName: String,
         genreName: String
    ) {
        _trackName = trackName
        _artistName = artistName
        _albumName = albumName
        _genreName = genreName
        _readFromItem = false
        _instance = nil
    }
    
    init(item: MPMediaItem) {
        _instance = item
        _readFromItem = true
        _trackName = ""
        _artistName = ""
        _albumName = ""
        _genreName = ""
    }
    
    var mediaItem: MPMediaItem {
        get {
            return _instance!
        }
    }
    
    var trackName: String {
        get {
            if (_readFromItem == false) {
                return _trackName
            }
            else {
                let temp = _instance!.value(forProperty: MPMediaItemPropertyTitle)
                
                if (temp == nil) {
                    return ""
                }
                else {
                    let returnValue = temp as! String
                
                    return returnValue
                }
            }
        }
    }
    
    var albumName: String {
        get {
            if (_readFromItem == false) {
                return _albumName
            }
            else {
                let temp = _instance!.value(forProperty: MPMediaItemPropertyAlbumTitle)
                
                if (temp == nil) {
                    return ""
                }
                else {
                    let returnValue = temp as! String
                
                    return returnValue
                }
            }
        }
    }
    
    var artistName: String {
        get {
            if (_readFromItem == false) {
                return _artistName
            }
            else {
                let temp = _instance!.value(forProperty: MPMediaItemPropertyArtist)
                
                if (temp == nil) {
                    return ""
                }
                else {
                    let returnValue = temp as! String
                
                    return returnValue
                }
            }
        }
    }
    
    var genreName: String {
        get {
            if (_readFromItem == false) {
                return _genreName
            }
            else {
                let temp = _instance!.value(forProperty: MPMediaItemPropertyGenre)
                
                if (temp == nil) {
                    return ""
                }
                else {
                    let returnValue = temp as! String
                
                    return returnValue
                }
            }
        }
    }
}
