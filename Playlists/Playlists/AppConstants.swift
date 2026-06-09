//
//  AppConstants.swift
//  Random Playlist Generator (iOS)
//
//  Created by Benjamin Day on 4/10/25.
//


import Foundation
import SwiftUI

enum AppConstants {
    static let PLAYLIST_MODE_ALL = "Mode: All"
    static let PLAYLIST_MODE_CATEGORY = "Mode: Category"
    static let PLAYLIST_MODE_RANDOMIZE_ARTIST = "Mode: Randomize Artist"
    static let PLAYLIST_MODE_RANDOMIZE_GENRE = "Mode: Randomize Genre"
    static let PLAYLIST_MODE_FAVORITES = "Mode: Favorites"
    static let NUMBER_OF_TRACKS_IN_PLAYLIST = 150

    // Name of the dynamic playlist Apple Music maintains when you Favorite songs
    // (iOS 17.2+). Centralized here because it may be localized / change.
    static let FAVORITE_SONGS_PLAYLIST_NAME = "Favorite Songs"
}
