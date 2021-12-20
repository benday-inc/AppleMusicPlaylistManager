//
//  PlaylistInfo.swift
//  PlaylistEditor (iOS)
//
//  Created by Benjamin Day on 12/20/21.
//

import Foundation

struct PlaylistItem: Identifiable, Hashable {
    var id = UUID()
    var name: String
}
