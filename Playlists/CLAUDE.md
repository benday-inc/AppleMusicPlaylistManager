# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Random Playlist Generator is an iOS app built with SwiftUI that creates randomized playlists from the user's Apple Music library. The app supports both phone UI and CarPlay interface, allowing users to organize music into categories and exclude unwanted content.

## Build & Test Commands

### Building
```bash
# Open project in Xcode (required - command line tools alone won't work)
open Playlists.xcodeproj

# Build from Xcode: Product > Build (⌘B)
```

### Testing
```bash
# Run tests from Xcode: Product > Test (⌘U)
# Or run specific test file: Right-click test file > Run tests
```

### Running
- Select target device/simulator in Xcode
- Product > Run (⌘R)
- For CarPlay testing, use CarPlay simulator in Xcode

## Architecture

### Core Data Flow

The app uses a **shared singleton pattern** for data management:

1. **PlaylistDataStore.shared**: Central data store used by both main app and CarPlay
   - Loads/saves exclusions (genres, artists, albums) and categories to JSON files
   - Persists to Documents directory using FileManager
   - Implements async loading with concurrent file operations
   - Marked as `@unchecked Sendable` for cross-context usage

2. **Main App Flow**: PlaylistsApp → ContentView → TabView with 4 tabs:
   - CategoryListView (manage categories)
   - SongsView (build playlists)
   - ExclusionsView (manage exclusions)
   - AboutView

3. **CarPlay Flow**: CarPlaySceneDelegate → CPTabBarTemplate
   - Waits for PlaylistDataStore.shared to load before showing UI
   - Displays categories in sortable list
   - Clicking category immediately plays songs using SongsViewModel

### Key Architectural Patterns

**MVVM with SwiftUI**:
- Models: `Category`, `MediaItemWrapper`, `IdentifiableString`
- ViewModels: `SongsViewModel`, `CategoryListViewModel`, `CategoryViewModel`
- Views: SwiftUI views in separate files
- All ViewModels conform to `ObservableObject` for reactive UI updates

**Music Library Integration**:
- Uses `MediaPlayer` framework (`MPMediaQuery`, `MPMusicPlayerController`)
- Wraps `MPMediaItem` in `MediaItemWrapper` for SwiftUI compatibility
- Requires Music Library authorization via `MusicKit`

**Playlist Modes** (defined in AppConstants):
- `PLAYLIST_MODE_ALL`: Random songs from entire library
- `PLAYLIST_MODE_CATEGORY`: Songs from selected category's artists/genres
- `PLAYLIST_MODE_RANDOMIZE_ARTIST`: Songs from specific artist
- `PLAYLIST_MODE_RANDOMIZE_GENRE`: Songs from specific genre

**Data Persistence**:
- JSON files in Documents directory:
  - `excluded-genres.data`
  - `excluded-artists.data`
  - `excluded-albums.data`
  - `categories.data`
- All save operations are async on background queue
- Load operations use `async let` for parallel execution

### Important Implementation Details

**SongsViewModel Playlist Generation**:
1. Queries MediaPlayer for all matching songs (stores in `allItems`)
2. Generates random indexes (default: 150 tracks per `AppConstants.NUMBER_OF_TRACKS_IN_PLAYLIST`)
3. Filters out excluded items based on current playlist mode
4. Preserves "pinned" items from `multiSelection` set
5. Plays via `MPMusicPlayerController.systemMusicPlayer`

**Category System**:
- Categories contain arrays of `artists` and `genres` (both `[String]`)
- CategoryListViewModel manages filtering, sorting (case-insensitive), and persistence
- Uses Combine framework for event propagation (`didSave` PassthroughSubject)

**CarPlay Integration**:
- Requires `com.apple.developer.carplay-audio` entitlement
- CarPlaySceneDelegate manages CPInterfaceController lifecycle
- Shows "Now Playing" indicator (▶️) next to active category
- Updates template on category selection to reflect playing state

**Test Mode**:
- PlaylistDataStore supports test initializers that skip file I/O
- `CategoryUtilities.getPopulatedCategories()` creates mock data
- Test mode detected via `isTestMode` flag

### File Organization

```
Playlists/
├── Playlists/              # Main app source
│   ├── PlaylistsApp.swift  # App entry point
│   ├── PlaylistDataStore.swift  # Singleton data store
│   ├── CarPlaySceneDelegate.swift  # CarPlay integration
│   ├── Models:
│   │   ├── Category.swift
│   │   ├── MediaItemWrapper.swift
│   │   └── IdentifiableString.swift
│   ├── ViewModels:
│   │   ├── SongsViewModel.swift
│   │   ├── CategoryListViewModel.swift
│   │   └── CategoryViewModel.swift
│   └── Views:
│       ├── ContentView.swift
│       ├── CategoryListView.swift
│       ├── SongsView.swift
│       ├── ExclusionsView.swift
│       └── [other views]
├── PlaylistsTests/         # Unit tests
└── PlaylistsUITests/       # UI tests
```

## Common Gotchas

- **Shared State**: Always use `PlaylistDataStore.shared` for data access in both app and CarPlay contexts
- **Exclusions Only Work in PLAYLIST_MODE_ALL**: Check `isExcluded()` implementation - exclusions are bypassed in category/artist/genre modes
- **CarPlay Requires Async Load Wait**: CarPlaySceneDelegate polls `dataStore.isLoaded` before showing UI
- **Album Exclusions Format**: Stored as "Artist - Album" concatenated string
- **MediaPlayer Queries**: Predicates use `.contains` for artist, `.equalTo` for genre
