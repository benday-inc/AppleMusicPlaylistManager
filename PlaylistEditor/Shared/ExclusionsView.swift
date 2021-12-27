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
            List(storage.excludedGenres){ item in
                Text(item.value).swipeActions(
                    edge: .trailing, allowsFullSwipe: true, content: {
                    Button(role: .destructive) {
                        if let index = storage.excludedGenres.firstIndex(of: item) {
                            storage.excludedGenres.remove(at: index)
                        }
                    } label: {
                       Label("Delete", systemImage: "trash")
                   }
                })
            }
            Text("Count: \(storage.excludedGenres.count)")
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
