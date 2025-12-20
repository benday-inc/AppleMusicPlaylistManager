# RND Shuffle

**Rediscover Your Music Library**

Built by a jazz musician with too much music.

## The Problem

Standard shuffle lies to you. Ask Siri to "play some music" or hit shuffle in Apple Music, and you'll hear the same familiar tracks over and over. If you've got a big library, most of it never gets played.

## The Solution

RND Shuffle uses cryptographic randomization to generate playlists that actually feel random. You'll rediscover albums you forgot you owned.

## Features

- **Custom Categories** — Create your own groupings by combining artists, genres, and composers (e.g., "Jazz Piano", "Early Music", or "Workout Mix")
- **Exclusions** — Filter out what you don't want in your shuffle (spoken word, comedy, meditation tracks, etc.)
- **CarPlay Support** — Quick access to your categories while driving
- **iCloud Sync** — Your categories and exclusions sync across all your devices
- **Playlist Export** — Save generated playlists to your Apple Music library
- **Works with your existing Apple Music library** — No subscriptions, no imports, no setup

## Platforms

- iPhone
- iPad
- Mac (Designed for iPad)

## Requirements

- iOS 17.0+ / macOS 14.0+
- Apple Music library with local/downloaded content
- Xcode 15+ (for building from source)

## Building

```bash
git clone https://github.com/benday-inc/AppleMusicPlaylistManager.git
cd AppleMusicPlaylistManager/Playlists
open Playlists.xcodeproj
```

Build and run from Xcode (⌘R).

For CarPlay testing, use the CarPlay simulator in Xcode.

## Usage

### Creating Categories

Categories let you group artists, genres, and composers together for targeted playlist generation.

1. Navigate to the **Categories** tab
2. Tap **+** to create a new category
3. Add artists, genres, or composers by searching your music library
4. Save the category

### Generating Playlists

1. Navigate to the **Random Music** tab
2. Tap the shuffle button to generate a random playlist
3. Use Edit mode to:
   - Remove unwanted tracks
   - Pin tracks you want to keep during regeneration
   - Reorder tracks
4. Tap **Play** to start playback or **Save** to export to Apple Music

### Managing Exclusions

Prevent certain content from appearing in random playlists:

1. Navigate to the **Exclusions** tab
2. Add genres, artists, or albums you want to exclude
3. Exclusions apply when generating random playlists from your entire library

### CarPlay

When connected to CarPlay:

1. Select a category to immediately start playing a randomized playlist from that category
2. Use the **Random Music** option for a playlist from your entire library
3. The currently playing category shows a play indicator

## Architecture

The app follows the **MVVM pattern** with SwiftUI:

- **Models**: `Category`, `MediaItemWrapper`, `IdentifiableString`
- **ViewModels**: `SongsViewModel`, `CategoryListViewModel`, `CategoryViewModel`
- **Views**: SwiftUI views for each screen

Data is persisted as JSON files and synced via iCloud Documents when available.

## Privacy

RND Shuffle has no ads, no tracking, and no analytics. Your music library data stays on your device (and in your iCloud if sync is enabled).

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Author

Benjamin Day
[benday.com](https://www.benday.com)
[@benday](https://www.youtube.com/@benday)

## License

[MIT License](LICENSE) — do whatever you want with it.
