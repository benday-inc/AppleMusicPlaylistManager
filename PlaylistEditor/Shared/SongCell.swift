//
//  SongCell.swift
//  PlaylistEditor (iOS)
//
//  Created by Benjamin Day on 12/26/21.
//

import SwiftUI

struct SongCell: View {
    var item: MediaItemWrapper
    
    var body: some View {
        Label("\(item.artistName) - \(item.trackName)", systemImage: "music.note.list").allowsTightening(true)
    }
}

struct SongCell_Previews: PreviewProvider {
    static var previews: some View {
        SongCell(item: MediaItemWrapper(trackName: "track name 1", albumName: "album name 1", artistName: "artist name 1"))
    }
}
