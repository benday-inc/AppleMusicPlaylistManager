# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an iOS SwiftUI application called "Random Playlist Generator" that manages Apple Music playlists with CarPlay support. The app allows users to create categories for organizing music preferences and generate random playlists based on those categories.

## Development Commands

### Building and Testing
```bash
# Build the project
xcodebuild -project Playlists.xcodeproj -scheme Playlists -configuration Debug build

# Run tests
xcodebuild -project Playlists.xcodeproj -scheme Playlists -destination 'platform=iOS Simulator,name=iPhone 15' test

# Build for release
xcodebuild -project Playlists.xcodeproj -scheme Playlists -configuration Release build
```

### Available Targets
- **Playlists**: Main iOS app target
- **PlaylistsTests**: Unit tests
- **PlaylistsUITests**: UI automation tests

## Architecture

### Core Components

**PlaylistDataStore** (`PlaylistDataStore.swift`): Singleton data store using `@Published` properties for reactive UI updates. Manages:
- Categories for playlist generation
- Excluded genres, artists, and albums
- Async data loading with shared state between main app and CarPlay

**ContentView** (`ContentView.swift`): Main SwiftUI view implementing TabView navigation with:
- Categories tab for managing playlist categories
- Additional tabs for different app sections
- Music authorization handling

**CarPlay Integration** (`CarPlaySceneDelegate.swift`): Dedicated CarPlay scene delegate implementing `CPTemplateApplicationSceneDelegate` for:
- Tab bar template navigation
- List templates for categories and songs
- Shared data store integration

### Key SwiftUI Views
- `CategoryListView`: Displays and manages playlist categories
- `SongsView`: Shows songs in playlists with playback controls
- `PlaylistsView`: Main playlist management interface
- `ExclusionsView`: Manages excluded artists, genres, and albums

### Data Models
- `Category`: Core playlist category model
- `IdentifiableString`: Wrapper for string collections in SwiftUI lists
- `MediaItemWrapper`: Wrapper for Apple Music media items

### Utilities
- `CategoryUtilities`: Helper functions for category operations
- `Debouncer`: Debouncing utility for search and input handling
- `Extensions`: SwiftUI and Foundation extensions

## Key Features

1. **Music Library Integration**: Uses MusicKit for Apple Music library access
2. **CarPlay Support**: Full CarPlay interface with template-based navigation
3. **Category-based Playlist Generation**: Create playlists based on user-defined categories
4. **Exclusion Lists**: Exclude specific artists, genres, or albums from playlists
5. **Reactive Data Flow**: ObservableObject pattern with @Published properties

## Testing

The project includes both unit tests (`PlaylistsTests`) and UI tests (`PlaylistsUITests`). Tests should be run using Xcode's built-in testing infrastructure or xcodebuild commands.

## Development Notes

- The app requires iOS music library permissions (handled in `MusicLibraryAuthorizationView`)
- CarPlay functionality is conditional and requires CarPlay-enabled simulators or devices for testing
- Data persistence is handled through the singleton `PlaylistDataStore.shared` instance
- The codebase follows SwiftUI best practices with MVVM architecture patterns