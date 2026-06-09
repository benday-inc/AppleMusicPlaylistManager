//
//  SongsViewModel.swift
//  Random Playlist Generator (iOS)
//
//  Created by Benjamin Day on 4/20/25.
//

import Foundation
import MediaPlayer

class SongsViewModel : ObservableObject {
    @Published public var guid: String
    @Published public var items: [MediaItemWrapper] = []
    @Published public var allItems: [MediaItemWrapper]? = nil
    
    @Published var currentArtist: String = ""
    @Published var currentGenre: String = ""
    
    @Published var playlistMode: String = "Mode: All"
    
    @Published var multiSelection = Set<UUID>()
    
    private var storage: PlaylistDataStore
    
    private var forCategory: Category?
    
    private var isPreview = false
    
    init (storage: PlaylistDataStore) {
        self.storage = storage
        self.guid = UUID().uuidString
    }
    
    init (category: Category, storage: PlaylistDataStore) {
        forCategory = category
        self.storage = storage
        self.guid = UUID().uuidString
        handleGetRandomSongs()
        play()
    }
    
    init(testItems: [MediaItemWrapper], storage: PlaylistDataStore) {
        isPreview = true
        
        self.storage = storage
        
        self.guid = UUID().uuidString
        
        items.append(contentsOf: testItems)        
    }
    
    private func removeExcluded() {
        removeExcluded(items: items)        
    }
    
    private func removeExcluded(items: [MediaItemWrapper]) {
        var removeThese = [MediaItemWrapper]()
        
        for item in items {
            if (storage.isExcluded(item: item, playlistMode: playlistMode) == true) {
                print("Removing excluded item: \(item.artistName) - \(item.trackName)")
                removeThese.append(item)
            }
        }
        
        print("Found \(removeThese.count) excluded items.")
        print("Items has \(items.count) before removing...")
        
        for item in removeThese {
            removeItem(item: item)
        }
        
        print("Items has \(items.count) after removing.")
    }
    
    public func removeItem(item: MediaItemWrapper) {
        let removeAtIndex = items.firstIndex(where: { $0.id == item.id })
        
        if (removeAtIndex != nil) {
            items.remove(at: removeAtIndex!)
        }
        
        print("removeItem(): Items has \(items.count) after removing.")
    }
    
    public func addAlbumExclusion(item: MediaItemWrapper) {
        storage.addAlbumExclusion(item: item)
        removeExcluded()
        print("SongsViewModel: item count is now \(items.count)")
    }
    
    public func addGenreExclusion(item: MediaItemWrapper) {
        storage.addGenreExclusion(item: item)
        removeExcluded()
        print("SongsViewModel: item count is now \(items.count)")
    }
    
    public func addArtistExclusion(item: MediaItemWrapper) {
        storage.addArtistExclusion(item: item)
        removeExcluded()
        print("SongsViewModel: item count is now \(items.count)")
    }
    
    public func removeTrack(item: MediaItemWrapper) {
        removeItem(item: item)
        print("SongsViewModel: item count is now \(items.count)")
    }
    
    public func move(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }
    
    public func removeSelected() {
        if (multiSelection.isEmpty == false) {
            for id in multiSelection {
                if let index = items.lastIndex(where: { $0.id == id })  {
                    items.remove(at: index)
                }
            }
            multiSelection = Set<UUID>()
        }
    }
    
    public func changePlaylistMode() {
        var modes: [String] = [
            AppConstants.PLAYLIST_MODE_ALL
        ]
        
        if (forCategory != nil) {
            modes.append(AppConstants.PLAYLIST_MODE_CATEGORY)
        }
        
        let selectedIndex = modes.firstIndex(of: playlistMode)
        
        if (selectedIndex == nil) {
            playlistMode = modes[0]
        }
        else {
            if (selectedIndex! == modes.count - 1) {
                playlistMode = modes[0]
            }
            else {
                playlistMode = modes[selectedIndex! + 1]
            }
        }
        
        allItems = nil
        items = []
        handleGetRandomSongs()
    }
    
    private func populateResultsForArtists(artists: [String]) {
        
        var returnValues = Array<MediaItemWrapper>()
        
        for artist in artists {
            let query = getMediaQueryForArtist(artist: artist)
            
            if (query.items != nil) {
                for item in query.items! {
                    returnValues.append(MediaItemWrapper(item: item))
                }
            }
        }
        
        items = returnValues
        allItems = returnValues
    }
    
    private func handleGetAllSongsForCategory() {
        // guard forCategory
        guard let forCategory = forCategory else {
            populateResultsForWhenSomethingWentWrong()
            return
        }
        var returnValues = Array<MediaItemWrapper>()

        if (forCategory.genres.isEmpty == false) {
            for genre in forCategory.genres {
                let query = getMediaQueryForGenre(genre: genre)

                if (query.items != nil) {
                    for item in query.items! {
                        returnValues.append(MediaItemWrapper(item: item))
                    }
                }
            }
        }

        if (forCategory.artists.isEmpty == false) {
            for artist in forCategory.artists {
                let query = getMediaQueryForArtist(artist: artist)

                if (query.items != nil) {
                    for item in query.items! {
                        returnValues.append(MediaItemWrapper(item: item))
                    }
                }
            }
        }

        if (forCategory.composers.isEmpty == false) {
            for composer in forCategory.composers {
                let query = getMediaQueryForComposer(composer: composer)

                if (query.items != nil) {
                    for item in query.items! {
                        returnValues.append(MediaItemWrapper(item: item))
                    }
                }
            }
        }

        items = returnValues
        allItems = returnValues
    }
        
    private func populateResultsForWhenSomethingWentWrong() {
        populateResultsForMediaQuery(query: MPMediaQuery.songs())
    }
    
    private func handleGetAllSongs() {
        
        if (forCategory != nil) {
            handleGetAllSongsForCategory()
        }
        else if (playlistMode == AppConstants.PLAYLIST_MODE_FAVORITES) {
            populateResultsForFavorites()
        }
        else {
            var query: MPMediaQuery

            if (playlistMode == AppConstants.PLAYLIST_MODE_ALL) {
                query = MPMediaQuery.songs()
            }
            else if (playlistMode == AppConstants.PLAYLIST_MODE_RANDOMIZE_ARTIST) {
                query = getMediaQueryForArtist(artist: currentArtist)
            }
            else if (playlistMode == AppConstants.PLAYLIST_MODE_RANDOMIZE_GENRE) {
                query = getMediaQueryForGenre(genre: currentGenre)
            }
            else {
                let genre = playlistMode.replacingOccurrences(of: "Mode: ", with: "")
                
                query = getMediaQueryForGenre(genre: genre)
            }
            
            populateResultsForMediaQuery(query: query)
        }
    }
    
    private func getMediaQueryForArtist(artist: String) -> MPMediaQuery {
        let query = MPMediaQuery.songs()
        
        let predicate = MPMediaPropertyPredicate(
            value: artist,
            forProperty: MPMediaItemPropertyArtist,
            comparisonType: .contains
        )
        query.addFilterPredicate(predicate)
        
        return query
    }
    
    private func getMediaQueryForGenre(genre: String) -> MPMediaQuery {
        let query = MPMediaQuery.songs()

        let predicate = MPMediaPropertyPredicate(
            value: genre,
            forProperty: MPMediaItemPropertyGenre,
            comparisonType: .equalTo
        )

        query.addFilterPredicate(predicate)

        return query
    }

    private func getMediaQueryForComposer(composer: String) -> MPMediaQuery {
        let query = MPMediaQuery.songs()

        let predicate = MPMediaPropertyPredicate(
            value: composer,
            forProperty: MPMediaItemPropertyComposer,
            comparisonType: .contains
        )

        query.addFilterPredicate(predicate)

        return query
    }

    private func populateResultsForGenres(genres: [String]) {
        
        var returnValues = Array<MediaItemWrapper>()
        
        for genre in genres {
            let query = getMediaQueryForGenre(genre: genre)
            
            if (query.items != nil) {
                for item in query.items! {
                    returnValues.append(MediaItemWrapper(item: item))
                }
            }
        }
        
        items = returnValues
        allItems = returnValues
    }
    
    private func handleListPlaylistsAndSongsInPlaylists() {
        let myPlaylistQuery = MPMediaQuery.playlists()
        let playlists = myPlaylistQuery.collections
        for playlist in playlists! {
            print(playlist.value(forProperty: MPMediaPlaylistPropertyName)!)
            
            let songs = playlist.items
            for song in songs {
                let songTitle = song.value(forProperty: MPMediaItemPropertyTitle)
                print("\t\t", songTitle!)
            }
        }
    }
    
    private func populateResultsForMediaQuery(query: MPMediaQuery) {
        
        var returnValues = Array<MediaItemWrapper>()
        
        if (query.items != nil) {
            for item in query.items! {
                returnValues.append(MediaItemWrapper(item: item))
            }
        }
        
        items = returnValues
        allItems = returnValues
    }
    
    /// Fetches Apple Music's auto-maintained "Favorite Songs" playlist (iOS 17.2+)
    /// via MPMediaQuery. Returns nil if no playlist by that name is visible to the
    /// on-device media library.
    private func getFavoriteSongsPlaylist() -> MPMediaPlaylist? {
        let query = MPMediaQuery.playlists()

        let predicate = MPMediaPropertyPredicate(
            value: AppConstants.FAVORITE_SONGS_PLAYLIST_NAME,
            forProperty: MPMediaPlaylistPropertyName,
            comparisonType: .equalTo
        )
        query.addFilterPredicate(predicate)

        return query.collections?.first as? MPMediaPlaylist
    }

    private func populateResultsForFavorites() {
        guard let playlist = getFavoriteSongsPlaylist() else {
            // Diagnostic: dump every playlist name so we can see what IS visible
            // if the expected name isn't found (e.g. localized / not synced).
            print("Favorites: no playlist named '\(AppConstants.FAVORITE_SONGS_PLAYLIST_NAME)' found. Visible playlists:")
            let allPlaylists = MPMediaQuery.playlists().collections ?? []
            for playlist in allPlaylists {
                let name = playlist.value(forProperty: MPMediaPlaylistPropertyName) as? String ?? "(unnamed)"
                print("\t- \(name) (\(playlist.items.count) items)")
            }
            items = []
            allItems = []
            return
        }

        let returnValues = playlist.items.map { MediaItemWrapper(item: $0) }
        print("Favorites: found '\(AppConstants.FAVORITE_SONGS_PLAYLIST_NAME)' with \(returnValues.count) tracks.")

        items = returnValues
        allItems = returnValues
    }

    private func getRandomIndexes(maxIndex: Int, numberOfValuesToReturn: Int) -> Array<Int> {
        
        if (maxIndex == 0) {
            return [0]
        }
        else if (maxIndex == 1) {
            return [0, 1]
        }
        else {
            var returnValues = Array<Int>()
            
            for _ in 0...numberOfValuesToReturn {
                let randomValue = Int.random(in: 1..<maxIndex)
                
                if (returnValues.contains(randomValue) == false) {
                    returnValues.append(randomValue)
                }
            }
            
            
            
            return returnValues
        }
    }
    
    public func handleGetRandomSongs() {
        if (isPreview == true) {
            return
        }
        
        if (allItems == nil) {
            handleGetAllSongs()
        }
        
        let songCount = allItems!.count
        
        if (songCount == 0) {
            handleGetAllSongs()
        }
        
        let randomIndexes = getRandomIndexes(
            maxIndex: songCount,
            numberOfValuesToReturn: AppConstants.NUMBER_OF_TRACKS_IN_PLAYLIST)
        
        var newPlaylistItems = Array<MediaItemWrapper>()
        
        // copy pinned items to new playlist
        if (multiSelection.isEmpty == false) {
            for id in multiSelection {
                if let index = items.lastIndex(where: { $0.id == id })  {
                    newPlaylistItems.append(items[index])
                }
            }
            multiSelection = Set<UUID>()
        }
        
        // create random playlist
        for index in randomIndexes {
            if index >= allItems!.count {
                continue
            }
            
            let tempSong = allItems![index]
            
            if (storage.isExcluded(item: tempSong, playlistMode: playlistMode) == false) {
                newPlaylistItems.append(tempSong)
                // print("not excluded")
            }
            else {
                // print("excluded")
            }
        }
        
        // set new array to items for binding to UI
        items = newPlaylistItems
    }
    
    public func playNow(item: MediaItemWrapper) {
        if item.mediaItem == nil {
            return
        }
        
        let mediaItem = item.mediaItem
        
        playMediaItemsNow(items: [mediaItem!])
    }
    
    public func playMediaItemsNow(items: [MPMediaItem]) {
        let collection = MPMediaItemCollection(items: items)
        
        let musicPlayer = MPMusicPlayerController.systemMusicPlayer
        
        musicPlayer.prepend(MPMusicPlayerMediaItemQueueDescriptor(itemCollection: collection))
        
        musicPlayer.skipToNextItem()
    }
    
    public func playAlbum(item: MediaItemWrapper) {
        if item.mediaItem == nil {
            return
        }
        
        let mediaItem = item.mediaItem!
        
        let tracksInAlbum = getTracksInAlbum(of: mediaItem)
        
        playMediaItemsNow(items: tracksInAlbum)
    }
    
    public func getTracksInAlbum(of mediaItem: MPMediaItem) -> [MPMediaItem] {
        guard let albumTitle = mediaItem.albumTitle else {
            return []
        }

        let query = MPMediaQuery.songs()

        // Filter by album title
        let albumPredicate = MPMediaPropertyPredicate(
            value: albumTitle,
            forProperty: MPMediaItemPropertyAlbumTitle,
            comparisonType: .equalTo
        )
        query.addFilterPredicate(albumPredicate)

        if let artist = mediaItem.albumArtist {
            let artistPredicate = MPMediaPropertyPredicate(
                value: artist,
                forProperty: MPMediaItemPropertyAlbumArtist,
                comparisonType: .equalTo
            )
            query.addFilterPredicate(artistPredicate)
        }

        // Sort by track number if available
        let sortedTracks = query.items?.sorted {
            ($0.albumTrackNumber) < ($1.albumTrackNumber)
        }

        return sortedTracks ?? []
    }

    public func randomizeGenre(item: MediaItemWrapper) {
        let genre = item.genreName
        
        if (genre == "") {
            return
        }
        else {
            currentGenre = genre
            currentArtist = ""
            playlistMode = AppConstants.PLAYLIST_MODE_RANDOMIZE_GENRE
            
            allItems = nil
            items = Array<MediaItemWrapper>()
            handleGetRandomSongs()
        }
    }
    
    public func randomizeArtist(item: MediaItemWrapper) {
        let artist = item.artistName
        
        if (artist == "") {
            return
        }
        else {
            currentGenre = ""
            currentArtist = artist
            playlistMode = AppConstants.PLAYLIST_MODE_RANDOMIZE_ARTIST
            
            allItems = nil
            items = Array<MediaItemWrapper>()
            handleGetRandomSongs()
        }
    }
    
    public func randomizeFavorites() {
        currentGenre = ""
        currentArtist = ""
        playlistMode = AppConstants.PLAYLIST_MODE_FAVORITES

        allItems = nil
        items = Array<MediaItemWrapper>()
        handleGetRandomSongs()
    }

    public func play() {
        var mediaItems: [MPMediaItem] = []
        
        for track in items {
            if (track.mediaItem != nil) {
                mediaItems.append(track.mediaItem!)
            }
        }
        
        let musicPlayer = MPMusicPlayerController.systemMusicPlayer
        
        musicPlayer.setQueue(with: MPMediaItemCollection(items: mediaItems))
        
        musicPlayer.play()
    }
    
   
}
