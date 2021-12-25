//
//  PlaylistDetail.swift
//  PlaylistEditor (iOS)
//
//  Created by Benjamin Day on 12/25/21.
//

import SwiftUI

struct PlaylistDetail: View {
    
    let playlist: PlaylistItem
    
    var body: some View {
        Text("\(playlist.name)")
    }
}

struct PlaylistDetail_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistDetail(playlist: PlaylistItem(name: "playlist title"))
    }
}
