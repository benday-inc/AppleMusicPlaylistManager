//
//  PlaylistNameSheetView.swift
//  Random Playlist Generator (iOS)
//
//  Created by Benjamin Day on 4/21/25.
//

import SwiftUI
import MusicKit
import MediaPlayer
import Combine

struct PlaylistNameSheetView: View {
    @State var playlistName: String = ""
    @State var validationMessage: String = ""
    @State var isValidName: Bool = false
    @State var isDuplicate: Bool = false
    @Environment(\.isPreview) var isPreview
    
    @StateObject private var debouncer = Debouncer()
    
    var onCallback: ((_ doSave: Bool, _ playlistName: String) -> Void)? = nil
    
    init() {
        
    }
    
    init(onSave: @escaping (_ doSave: Bool, _ playlistName: String) -> Void) {
        self.onCallback = onSave
    }
    
    init(playlistName: String, validationMessage: String, isValidName: Bool, isDuplicate: Bool) {
        _playlistName = State(initialValue: playlistName)
        _validationMessage = State(initialValue: validationMessage)
        _isValidName = State(initialValue: isValidName)
        _isDuplicate = State(initialValue: isDuplicate)
    }
    
    func doCheckOfPlaylistName(_ newValue: String) {
        let result = isPlaylistNameValid(name: newValue)
        
        if (result == "valid") {
            isValidName = true
            isDuplicate = false
        }
        else if (result == "invalid:empty") {
            isValidName = false
            isDuplicate = false
            validationMessage = "Name cannot be empty."
        }
        else if (result == "invalid:duplicate") {
            isValidName = false
            isDuplicate = true
            validationMessage = "Playlist with this name already exists."
        }
        else {
            isValidName = false
            isDuplicate = false
            validationMessage = "Computer says no."
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Playlist Name")
                .bold()
                .font(.headline)
            
            Text("Enter a name for your playlist (e.g. Random playlist)")
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            TextField("Playlist Name", text: $playlistName)
                .textFieldStyle(.roundedBorder)
                .onChange(of: playlistName) { oldValue, newValue in
                    let trimmed = newValue.trimmingCharacters(in: .whitespaces)
                    
                    debouncer.input.send(trimmed)
                }
            
            if isValidName == false {
                Text(validationMessage)
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            HStack {
                Spacer()
                
                Button("Save") {
                    if (onCallback != nil && isValidName) {
                        onCallback?(true, playlistName)
                    }
                }
                .disabled(!isValidName)
                .opacity(!isValidName ? 0.75 : 1.0)
                
                Button("Cancel") {
                    if (onCallback != nil) {
                        onCallback?(false, playlistName)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .padding()
        .onAppear() {
            debouncer.start { playlistName in
                doCheckOfPlaylistName(playlistName)
            }
        }
        
#if isMacOS
        .onExitCommand(perform: {
            isPlaylistSheetVisible = false
        })
#endif
        Spacer()
    }
    
    
    func isPlaylistNameValid(name: String) -> String {
        if (name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
            return "invalid:empty"
        }
        else if (isPreview == true) {
            if (name == "valid") {
                return "valid"
            }
            else if (name == "duplicate") {
                return "invalid:duplicate"
            }
            else {
                return "invalid:other"
            }
        }
        else {
            let existingPlaylist = getPlaylistByName(playlistName: name)
            
            if (existingPlaylist != nil) {
                return "invalid:duplicate"
            }
            else {
                return "valid"
            }
        }
    }
    
    private func getPlaylistByName(playlistName: String) -> MPMediaPlaylist? {
        let myPlaylistQuery = MPMediaQuery.playlists()
        
        var returnValue: MPMediaPlaylist? = nil
        let pred = MPMediaPropertyPredicate(value: playlistName,
                                            forProperty: MPMediaPlaylistPropertyName)
        
        myPlaylistQuery.addFilterPredicate(pred)
        
        returnValue = myPlaylistQuery.collections?.first as? MPMediaPlaylist
        
        return returnValue
    }
}

#Preview {
    PlaylistNameSheetView()
}

#Preview("valid") {
    PlaylistNameSheetView(playlistName: "valid", validationMessage: "asdfasfd",
                          isValidName: true, isDuplicate: false)
}

#Preview("duplicate") {
    PlaylistNameSheetView(playlistName: "duplicate", validationMessage: "duplicate playlist name",
                          isValidName: false, isDuplicate: true)
}

#Preview("invalid other") {
    PlaylistNameSheetView(playlistName: "     ", validationMessage: "only spaces",
                          isValidName: false, isDuplicate: false)
}


