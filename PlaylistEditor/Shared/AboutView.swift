//
//  AboutView.swift
//  Random Playlist Generator (iOS)
//
//  Created by Benjamin Day on 4/21/25.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("Random Playlist Generator")
                .font(.title)
                .fontWeight(.bold)
            Text("Written by Benjamin Day")
                .font(.title)
            
            // Benday logo and link
            Link(destination: URL(string: "https://www.benday.com")!) {
                VStack {
                    Image("bdc-logo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .padding()
                    Text("www.benday.com")
                        .foregroundColor(.blue)
                        .underline()
                }
            }
            Link(destination: URL(string: "mailto:info@benday.com")!) {
                VStack {
                    Text("info@benday.com")
                        .foregroundColor(.blue)
                        .underline()
                }
            }

            // Slide Speaker logo and link
            Link(destination: URL(string: "https://www.slidespeaker.ai")!) {
                VStack {
                    Image("slide-speaker-logo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                    Text("www.slidespeaker.ai")
                        .foregroundColor(.blue)
                        .underline()
                }
            }
        }
        .padding()
    }
}

#Preview {
    AboutView()
}
