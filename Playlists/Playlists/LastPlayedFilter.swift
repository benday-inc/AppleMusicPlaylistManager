//
//  LastPlayedFilter.swift
//  Random Playlist Generator (iOS)
//

import Foundation
import MediaPlayer

/// Limits random playlists to songs that haven't been played recently.
/// Songs that have never been played always count as "not played recently".
enum LastPlayedFilter: Int, CaseIterable, Identifiable {
    case anyTime = 0
    case threeMonths = 3
    case sixMonths = 6
    case oneYear = 12
    case twoYears = 24

    // UserDefaults keys so the phone and CarPlay share each list's setting
    static let randomMusicKey = "lastPlayedFilter.randomMusic"
    static let favoritesKey = "lastPlayedFilter.favorites"

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .anyTime: return "Any Time"
        case .threeMonths: return "3+ Months Ago"
        case .sixMonths: return "6+ Months Ago"
        case .oneYear: return "1+ Year Ago"
        case .twoYears: return "2+ Years Ago"
        }
    }

    /// The next option, wrapping around. Used by CarPlay, which has no pickers.
    var next: LastPlayedFilter {
        let all = LastPlayedFilter.allCases
        let index = all.firstIndex(of: self)!
        return all[(index + 1) % all.count]
    }

    func includes(_ item: MPMediaItem?) -> Bool {
        if self == .anyTime {
            return true
        }

        guard let lastPlayed = item?.lastPlayedDate else {
            // never played
            return true
        }

        guard let cutoff = Calendar.current.date(byAdding: .month, value: -rawValue, to: Date()) else {
            return true
        }

        return lastPlayed < cutoff
    }

    static func load(key: String) -> LastPlayedFilter {
        return LastPlayedFilter(rawValue: UserDefaults.standard.integer(forKey: key)) ?? .anyTime
    }

    func save(key: String) {
        UserDefaults.standard.set(rawValue, forKey: key)
    }
}
