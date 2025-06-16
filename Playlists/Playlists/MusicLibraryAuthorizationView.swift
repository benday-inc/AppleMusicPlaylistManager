//
//  MusicLibraryAuthorizationView.swift
//  Random Playlist Generator (iOS)
//
//  Created by Benjamin Day on 3/23/25.
//

import SwiftUI
import MusicKit
import MediaPlayer

struct MusicLibraryAuthorizationView: View {
    @Binding var authorizationStatus: MusicAuthorization.Status
    @Environment(\.isPreview) var isPreview
    
    var body: some View {
        VStack {
            if authorizationStatus == .authorized {
                
            } else {
                Text("We need to get your permission to access your music library.")
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                
                Button("Click here to start the authorization process", action: {
                    Task {
                        let status = await MusicAuthorization.request()
                        // Ensure updates happen on the main thread.
                        await MainActor.run {
                            authorizationStatus = status
                        }
                    }
                })
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .padding(.all, 5.0)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .onAppear {
            if (isPreview == false) {
                authorizationStatus = MusicAuthorization.currentStatus
            }
            else {
                print(authorizationStatus)
            }
        }
    }
}

#Preview("not determined") {
    MusicLibraryAuthorizationView(authorizationStatus: .constant(.notDetermined))
}

#Preview("authorized") {
    MusicLibraryAuthorizationView(authorizationStatus: .constant(.authorized))
}

#Preview("denied") {
    MusicLibraryAuthorizationView(authorizationStatus: .constant(.denied))
}
