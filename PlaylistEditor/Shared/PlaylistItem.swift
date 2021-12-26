//
//  PlaylistInfo.swift
//  PlaylistEditor (iOS)
//
//  Created by Benjamin Day on 12/20/21.
//

import Foundation
import MusicKit
import MediaPlayer

struct PlaylistItem: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var instance: MPMediaItemCollection?
}


