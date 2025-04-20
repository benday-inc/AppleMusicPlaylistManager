//
//  SongsViewModel.swift
//  Random Playlist Generator (iOS)
//
//  Created by Benjamin Day on 4/20/25.
//

import Foundation
import MediaPlayer

class SongsViewModel : ObservableObject {
    @Published public var items: [MediaItemWrapper] = []
    @Published public var allItems: [MediaItemWrapper]? = []
    
    @Published var currentArtist: String = ""
    @Published var currentGenre: String = ""
    
    @Published var playlistMode: String = "Mode: All"
    
    @Published var multiSelection = Set<UUID>()
    
    private var storage: PlaylistDataStore
    
    private var isPreview = false
    
    init (storage: PlaylistDataStore) {
        self.storage = storage
    }
    
    init(testItems: [MediaItemWrapper], storage: PlaylistDataStore) {
        isPreview = true
        
        self.storage = storage
        
        items.append(contentsOf: testItems)        
    }
    
    public func removeExcluded(items: Array<MediaItemWrapper>) {
        var removeThese = Array<MediaItemWrapper>()
        
        for item in items {
            if (storage.isExcluded(item: item, playlistMode: playlistMode) == true) {
                removeThese.append(item)
            }
        }
        
        for item in removeThese {
            removeItem(item: item)
        }
    }
    
    public func removeItem(item: MediaItemWrapper) {
        let removeAtIndex = items.firstIndex(where: { $0.id == item.id })
        
        if (removeAtIndex != nil) {
            items.remove(at: removeAtIndex!)
        }
    }
    
    public func addAlbumExclusion(item: MediaItemWrapper) {
        storage.addAlbumExclusion(item: item)
        removeExcluded(items: items)
    }
    
    public func addGenreExclusion(item: MediaItemWrapper) {
        storage.addGenreExclusion(item: item)
        removeExcluded(items: items)
    }
    
    public func addArtistExclusion(item: MediaItemWrapper) {
        storage.addArtistExclusion(item: item)
        removeExcluded(items: items)
    }
    
    public func removeTrack(item: MediaItemWrapper) {
        removeItem(item: item)
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
        let modes: [String] = [
            AppConstants.PLAYLIST_MODE_ALL,
            AppConstants.PLAYLIST_MODE_JAZZ,
            AppConstants.PLAYLIST_MODE_RANDOMIZE_CATEGORY_LATIN,
            AppConstants.PLAYLIST_MODE_RANDOMIZE_CATEGORY_SMOOTH_JAZZ,
            AppConstants.PLAYLIST_MODE_CLASSICAL,
            AppConstants.PLAYLIST_MODE_YELLOWJACKETS,
            AppConstants.PLAYLIST_MODE_CHICK_COREA,
            AppConstants.PLAYLIST_MODE_RIPPINGTONS,
            AppConstants.PLAYLIST_MODE_SPYRO_GYRA,
            AppConstants.PLAYLIST_MODE_HENDRIE
        ]
        
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
    
    private func isGenreCategory(mode: String) -> Bool {
        if (mode == AppConstants.PLAYLIST_MODE_RANDOMIZE_CATEGORY_LATIN) {
            return true
        }
        else {
            return false
        }
    }
    
    private func isArtistCategory(mode: String) -> Bool {
        if (mode == AppConstants.PLAYLIST_MODE_RANDOMIZE_CATEGORY_SMOOTH_JAZZ) {
            return true
        }
        else {
            return false
        }
    }
    
    private func handleGetAllSongsForGenreCategory() {
        if (playlistMode == AppConstants.PLAYLIST_MODE_RANDOMIZE_CATEGORY_LATIN) {
            populateResultsForGenres(genres: ["Latin", "Latin Jazz", "Salsa", "Timba", "Música tropical"])
        }
        else {
            populateResultsForWhenSomethingWentWrong()
        }
    }
    
    private func handleGetAllSongsForArtistCategory() {
        if (playlistMode == AppConstants.PLAYLIST_MODE_RANDOMIZE_CATEGORY_SMOOTH_JAZZ) {
            let artists = [
                "Everette Harp",
                "Gerald Albright",
                "Nelson Rangell",
                "Torcuato Mariano",
                "Eric Marienthal",
                "Fourplay",
                "Jeff Kashiwa",
                "Spyro Gyra",
                "Rippingtons",
                "Russ Freeman",
                "Tom Schuman",
                "Jeff Lorber",
                "Brandon Fields",
                "Dave Koz",
                "Incognito",
                "Lee Ritenour",
                "Dave Samuels",
                "David Samuels",
                "Grover Washington",
                "Chuck Loeb",
                "Larry Carlton",
                "Najee",
                "Brian Culbertson"]
            
            populateResultsForArtists(artists: artists)
        }
        else {
            populateResultsForWhenSomethingWentWrong()
        }
    }
    
    private func populateResultsForWhenSomethingWentWrong() {
        populateResultsForMediaQuery(query: MPMediaQuery.songs())
    }
    
    private func handleGetAllSongs() {
        
        if (isGenreCategory(mode: playlistMode)) {
            handleGetAllSongsForGenreCategory()
        }
        else if (isArtistCategory(mode: playlistMode)) {
            handleGetAllSongsForArtistCategory()
        }
        else {
            var query: MPMediaQuery
            
            if (playlistMode == AppConstants.PLAYLIST_MODE_ALL) {
                query = MPMediaQuery.songs()
            }
            else if (playlistMode == AppConstants.PLAYLIST_MODE_HENDRIE) {
                query = getMediaQueryForArtist(artist: "Phil Hendrie")
            }
            else if (playlistMode == AppConstants.PLAYLIST_MODE_SPYRO_GYRA) {
                query = getMediaQueryForArtist(artist: "Spyro Gyra")
            }
            else if (playlistMode == AppConstants.PLAYLIST_MODE_RIPPINGTONS) {
                query = getMediaQueryForArtist(artist: "Rippingtons")
            }
            else if (playlistMode == AppConstants.PLAYLIST_MODE_YELLOWJACKETS) {
                query = getMediaQueryForArtist(artist: "Yellowjackets")
            }
            else if (playlistMode == AppConstants.PLAYLIST_MODE_CHICK_COREA) {
                query = getMediaQueryForArtist(artist: "Chick Corea")
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
