//
//  SongCell.swift
//  RandomPlaylistGenerator (iOS)
//
//  Created by Benjamin Day on 12/26/21.
//

import SwiftUI

struct SongCell: View {
    var item: MediaItemWrapper
    
    var body: some View {
        HStack {
            Image(systemName: "music.note.list")
            VStack(alignment: .leading) {
                Text(item.trackName).font(.title2).fontWeight(.bold).multilineTextAlignment(.leading)
                Text("\(item.artistName) - \(item.albumName)")
                    .multilineTextAlignment(.center)
                Text(item.genreName).font(.footnote).fontWeight(.thin).multilineTextAlignment(.leading)
            }
        }
    }    
}

struct SongCell_Previews: PreviewProvider {
    static var previews: some View {
        SongCell(item: MediaItemWrapper(trackName: "track name 1", albumName: "album name 1", artistName: "artist name 1"))
    }
}
