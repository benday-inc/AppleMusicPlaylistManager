//
//  IdentifiableString.swift
//  PlaylistEditor (iOS)
//
//  Created by Benjamin Day on 12/27/21.
//

import Foundation
import MusicKit
import MediaPlayer

struct IdentifiableString: Identifiable, Hashable, Encodable, Decodable {
    var id = UUID()
    var value: String
}

