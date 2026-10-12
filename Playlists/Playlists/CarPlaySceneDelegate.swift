import CarPlay
import MediaPlayer
import UIKit

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate, CPNowPlayingTemplateObserver {

    // CarPlay plays through this app's own queue player instead of the system
    // Music app. That makes this app the "now playing" app in the car, so the
    // Now Playing widget, Now Playing screen, and steering-wheel controls work.
    // Requires the "audio" background mode to keep playing when you switch to
    // Maps etc.
    private let musicPlayer = MPMusicPlayerController.applicationQueuePlayer

    var interfaceController: CPInterfaceController?
    var playingCategoryId: UUID?
    var categoryListTemplate: CPListTemplate?
    var tabBarTemplate: CPTabBarTemplate?
    var randomMusicViewModel: SongsViewModel?
    var favoritesViewModel: SongsViewModel?

    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController

        configureNowPlayingTemplate()

        // Use shared data store instance
        let dataStore = PlaylistDataStore.shared

        Task { @MainActor in
            // Wait for the data store to be fully loaded
            while !dataStore.isLoaded {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            }
            await setupAndShowTabBar(with: dataStore)
        }
    }

    // CarPlay disconnected
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                          didDisconnectInterfaceController interfaceController: CPInterfaceController) {
        CPNowPlayingTemplate.shared.remove(self)
        self.interfaceController = nil
        self.categoryListTemplate = nil
        self.tabBarTemplate = nil
        self.playingCategoryId = nil
        self.randomMusicViewModel = nil
        self.favoritesViewModel = nil
        // Keep dataStore around for potential reconnection
    }

    private func setupAndShowTabBar(with dataStore: PlaylistDataStore) async {
        let categoryTemplate = CPListTemplate(title: "Click a category to play its songs", sections: [])
        categoryTemplate.tabTitle = "Categories"
        categoryTemplate.tabImage = UIImage(systemName: "music.note.list")
        self.categoryListTemplate = categoryTemplate
        refreshCategoryList(with: dataStore)

        let randomViewModel = SongsViewModel(storage: dataStore, musicPlayer: musicPlayer)
        randomViewModel.useSavedLastPlayedFilter(key: LastPlayedFilter.randomMusicKey)
        randomViewModel.handleGetRandomSongs()
        self.randomMusicViewModel = randomViewModel
        let randomMusicTemplate = makeSongListTemplate(
            title: "Random Music",
            tabImage: UIImage(systemName: "shuffle"),
            viewModel: randomViewModel,
            playAllDetail: "Play the current random playlist",
            refreshDetail: "Generate new random playlist")

        let favoritesViewModel = SongsViewModel(storage: dataStore, musicPlayer: musicPlayer)
        favoritesViewModel.useSavedLastPlayedFilter(key: LastPlayedFilter.favoritesKey)
        favoritesViewModel.randomizeFavorites()
        self.favoritesViewModel = favoritesViewModel
        let favoritesTemplate = makeSongListTemplate(
            title: "Favorites",
            tabImage: UIImage(systemName: "star.fill"),
            viewModel: favoritesViewModel,
            playAllDetail: "Play the current favorites playlist",
            refreshDetail: "Shuffle favorites again")

        let tabBar = CPTabBarTemplate(templates: [categoryTemplate, randomMusicTemplate, favoritesTemplate])
        self.tabBarTemplate = tabBar
        interfaceController?.setRootTemplate(tabBar, animated: true) { success, error in
            if let error = error {
                print("Failed to set root template: \(error)")
            }
        }
    }

    // MARK: - Categories

    private func refreshCategoryList(with dataStore: PlaylistDataStore) {
        let items = dataStore.categories
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            .map { category in
                let item = CPListItem(text: category.name, detailText: nil)
                item.isPlaying = category.id == self.playingCategoryId
                item.handler = { [weak self] _, completion in
                    guard let self = self else { completion(); return }
                    self.playingCategoryId = category.id
                    // This initializer generates the playlist and starts playing it
                    _ = SongsViewModel(category: category, storage: dataStore, musicPlayer: self.musicPlayer)
                    self.refreshCategoryList(with: dataStore)
                    self.showNowPlaying()
                    completion()
                }
                return item
            }

        categoryListTemplate?.updateSections([CPListSection(items: items)])
    }

    /// Called when something other than a category starts playing.
    private func clearPlayingCategory() {
        guard playingCategoryId != nil else { return }
        playingCategoryId = nil
        refreshCategoryList(with: PlaylistDataStore.shared)
    }

    // MARK: - Random Music & Favorites

    private func makeSongListTemplate(
        title: String,
        tabImage: UIImage?,
        viewModel: SongsViewModel,
        playAllDetail: String,
        refreshDetail: String) -> CPListTemplate {
        let template = CPListTemplate(title: title, sections: [])
        template.tabTitle = title
        template.tabImage = tabImage
        template.updateSections(makeSongListSections(
            template: template,
            viewModel: viewModel,
            playAllDetail: playAllDetail,
            refreshDetail: refreshDetail))
        return template
    }

    private func makeSongListSections(
        template: CPListTemplate,
        viewModel: SongsViewModel,
        playAllDetail: String,
        refreshDetail: String) -> [CPListSection] {
        let playButton = CPListItem(text: "▶️ Play All", detailText: playAllDetail)
        playButton.handler = { [weak self] _, completion in
            viewModel.play()
            self?.clearPlayingCategory()
            self?.showNowPlaying()
            completion()
        }

        let refreshButton = CPListItem(text: "🔄 Refresh", detailText: refreshDetail)
        refreshButton.handler = { [weak self, weak template] _, completion in
            guard let self = self, let template = template else { completion(); return }
            viewModel.handleGetRandomSongs()
            template.updateSections(self.makeSongListSections(
                template: template,
                viewModel: viewModel,
                playAllDetail: playAllDetail,
                refreshDetail: refreshDetail))
            completion()
        }

        // CarPlay has no pickers, so tapping this row cycles through the options
        let lastPlayedButton = CPListItem(
            text: "🕰️ Last Played: \(viewModel.lastPlayedFilter.title)",
            detailText: "Tap to change · never-played songs always included")
        lastPlayedButton.handler = { [weak self, weak template] _, completion in
            guard let self = self, let template = template else { completion(); return }
            viewModel.changeLastPlayedFilter(to: viewModel.lastPlayedFilter.next)
            template.updateSections(self.makeSongListSections(
                template: template,
                viewModel: viewModel,
                playAllDetail: playAllDetail,
                refreshDetail: refreshDetail))
            completion()
        }

        let buttonSection = CPListSection(items: [playButton, refreshButton, lastPlayedButton])

        // Tapping a song plays the playlist starting from that song
        let songItems = viewModel.items.map { song in
            let item = CPListItem(text: song.trackName, detailText: song.artistName)
            item.handler = { [weak self] _, completion in
                viewModel.play(startingAt: song)
                self?.clearPlayingCategory()
                self?.showNowPlaying()
                completion()
            }
            return item
        }

        let songsSection = CPListSection(items: songItems, header: "Songs", sectionIndexTitle: nil)

        return [buttonSection, songsSection]
    }

    // MARK: - Now Playing

    private func configureNowPlayingTemplate() {
        let nowPlaying = CPNowPlayingTemplate.shared
        nowPlaying.isUpNextButtonEnabled = true
        nowPlaying.upNextTitle = "Up Next"
        nowPlaying.updateNowPlayingButtons([
            makeNowPlayingButton(systemImage: "square.stack") { [weak self] in
                self?.playCurrentAlbum()
            },
            makeNowPlayingButton(systemImage: "music.mic") { [weak self] in
                self?.shuffleCurrentArtist()
            },
            makeNowPlayingButton(systemImage: "guitars") { [weak self] in
                self?.shuffleCurrentGenre()
            }
        ])
        nowPlaying.add(self)
    }

    private func makeNowPlayingButton(systemImage: String, action: @escaping () -> Void) -> CPNowPlayingButton {
        let image = UIImage(systemName: systemImage) ?? UIImage()
        return CPNowPlayingImageButton(image: image) { _ in action() }
    }

    private func showNowPlaying() {
        guard let interfaceController = interfaceController,
              interfaceController.topTemplate !== CPNowPlayingTemplate.shared else {
            return
        }
        interfaceController.pushTemplate(CPNowPlayingTemplate.shared, animated: true, completion: nil)
    }
    
    private func currentTrack() -> MediaItemWrapper? {
        guard let mediaItem = musicPlayer.nowPlayingItem else { return nil }
        return MediaItemWrapper(item: mediaItem)
    }

    /// Plays the current song's album next; the rest of the queue continues afterwards.
    private func playCurrentAlbum() {
        guard let track = currentTrack() else { return }
        SongsViewModel(storage: PlaylistDataStore.shared, musicPlayer: musicPlayer).playAlbum(item: track)
    }

    private func shuffleCurrentArtist() {
        guard let track = currentTrack() else { return }
        let viewModel = SongsViewModel(storage: PlaylistDataStore.shared, musicPlayer: musicPlayer)
        viewModel.randomizeArtist(item: track)
        viewModel.play()
        clearPlayingCategory()
    }

    private func shuffleCurrentGenre() {
        guard let track = currentTrack() else { return }
        let viewModel = SongsViewModel(storage: PlaylistDataStore.shared, musicPlayer: musicPlayer)
        viewModel.randomizeGenre(item: track)
        viewModel.play()
        clearPlayingCategory()
    }

    func nowPlayingTemplateUpNextButtonTapped(_ nowPlayingTemplate: CPNowPlayingTemplate) {
        // The queue can only be read inside a queue transaction; an empty
        // transaction leaves it unchanged.
        musicPlayer.perform(queueTransaction: { _ in }) { [weak self] queue, error in
            if let error = error {
                print("Failed to read the play queue: \(error)")
            }
            let queuedItems = queue.items
            DispatchQueue.main.async {
                self?.showUpNext(queuedItems: queuedItems)
            }
        }
    }

    private func showUpNext(queuedItems: [MPMediaItem]) {
        let currentIndex = musicPlayer.indexOfNowPlayingItem
        let upcoming = currentIndex == NSNotFound ? [] : Array(queuedItems.dropFirst(currentIndex + 1))

        let items = upcoming
            .prefix(Int(CPListTemplate.maximumItemCount))
            .map { mediaItem in
                let item = CPListItem(text: mediaItem.title ?? "", detailText: mediaItem.artist)
                item.handler = { [weak self] _, completion in
                    self?.musicPlayer.nowPlayingItem = mediaItem
                    self?.musicPlayer.play()
                    self?.interfaceController?.popTemplate(animated: true, completion: nil)
                    completion()
                }
                return item
            }

        let template = CPListTemplate(title: "Up Next", sections: [CPListSection(items: items)])
        template.emptyViewTitleVariants = ["Nothing queued"]
        interfaceController?.pushTemplate(template, animated: true, completion: nil)
    }
}
