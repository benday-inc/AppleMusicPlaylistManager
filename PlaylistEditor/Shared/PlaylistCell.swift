//
//  PlaylistCell.swift
//  RandomPlaylistGenerator (iOS)
//
//  Created by Benjamin Day on 12/26/21.
//

import SwiftUI

struct PlaylistCell: View {
    var playlist: PlaylistItem
    
    var body: some View {
        NavigationLink(destination: PlaylistDetail(playlist: playlist)) {
            Label("\(playlist.name)", systemImage: "music.note.list").allowsTightening(true)
        }
    }
}

struct PlaylistCell_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistCell(playlist: PlaylistItem(name: "three threethree threethree threethree threethree threethree threethree threethree threethree threethree threethree threethree three"))
    }
}
