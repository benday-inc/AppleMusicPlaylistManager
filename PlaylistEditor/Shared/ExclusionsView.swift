//
//  ExclusionsView.swift
//  PlaylistEditor (iOS)
//
//  Created by Benjamin Day on 12/27/21.
//

import SwiftUI

struct ExclusionsView: View {
    @EnvironmentObject var storage: PlaylistDataStore
    
    var body: some View {
        VStack {
            Form() {
                Section(header: Text("Excluded Genres")) {
                    if (storage.excludedGenres.isEmpty) {
                        Text("(none)")
                    }
                    else {
                        List(storage.excludedGenres){ item in
                            Text(item.value).swipeActions(
                                edge: .trailing, allowsFullSwipe: true, content: {
                                Button(role: .destructive) {
                                    storage.removeGenreExclusion(item: item)
                                } label: {
                                   Label("Delete", systemImage: "trash")
                               }
                            })
                        }
                    }
                }
                Section(header: Text("Excluded Artists")) {
                    if (storage.excludedArtists.isEmpty) {
                        Text("(none)")
                    }
                    else {
                        List(storage.excludedArtists){ item in
                            Text(item.value).swipeActions(
                                edge: .trailing, allowsFullSwipe: true, content: {
                                Button(role: .destructive) {
                                    storage.removeArtistExclusion(item: item)
                                } label: {
                                   Label("Delete", systemImage: "trash")
                               }
                            })
                        }
                    }
                }
                Section(header: Text("Excluded Albums")) {
                    if (storage.excludedAlbums.isEmpty) {
                        Text("(none)")
                    }
                    else {
                        List(storage.excludedAlbums){ item in
                            Text(item.value).swipeActions(
                                edge: .trailing, allowsFullSwipe: true, content: {
                                Button(role: .destructive) {
                                    storage.removeAlbumExclusion(item: item)
                                } label: {
                                   Label("Delete", systemImage: "trash")
                               }
                            })
                        }
                    }
                }
            }

            
        }
    }
    
}

struct ExclusionsView_Previews: PreviewProvider {
    static var testData: [IdentifiableString] = [
        IdentifiableString(value: "genre 1"),
        IdentifiableString(value: "genre 2"),
        IdentifiableString(value: "genre 3"),
        IdentifiableString(value: "genre 4")
    ]
        
    static var previews: some View {
        
        ExclusionsView().environmentObject(PlaylistDataStore(testData: ExclusionsView_Previews.testData))
    }
}
