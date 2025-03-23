//
//  EnvironmentValues.swift
//  Random Playlist Generator (iOS)
//
//  Created by Benjamin Day on 3/23/25.
//


import SwiftUI
import MusicKit
import MediaPlayer

public extension EnvironmentValues {
    var isPreview: Bool {
#if DEBUG
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
#else
        return false
#endif
    }
}
