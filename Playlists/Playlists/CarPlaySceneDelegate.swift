import CarPlay
import UIKit

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    
    var interfaceController: CPInterfaceController?
    var playingCategoryId: UUID?
    var categoryListTemplate: CPListTemplate?
    var tabBarTemplate: CPTabBarTemplate?
    var randomMusicViewModel: SongsViewModel?
    var randomMusicListTemplate: CPListTemplate?
    
    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        
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
        self.interfaceController = nil
        self.categoryListTemplate = nil
        self.tabBarTemplate = nil
        self.playingCategoryId = nil
        self.randomMusicViewModel = nil
        self.randomMusicListTemplate = nil
        // Keep dataStore around for potential reconnection
    }
    
    private func getCategoryListTemplate(with dataStore: PlaylistDataStore) -> CPListTemplate {
        let items = dataStore.categories
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            .map { category in
                let isPlaying = category.id == self.playingCategoryId
                let displayTitle = isPlaying ? "▶️ \(category.name)" : category.name
                let detailText = isPlaying ? "Now Playing" : nil
                let item = CPListItem(text: displayTitle, detailText: detailText)
                item.handler = { [weak self] _, completion in
                    guard let self = self else { completion(); return }
                    self.playingCategoryId = category.id
                    let viewModel = SongsViewModel(category: category, storage: dataStore)
                    viewModel.play()
                    Task { await self.reloadCategoryList(with: dataStore) }
                    completion()
                }
                return item
            }
        let section = CPListSection(items: items)
        let listTemplate = CPListTemplate(title: "Click a category to play its songs", sections: [section])
        listTemplate.tabTitle = "Categories"
        listTemplate.tabImage = UIImage(systemName: "music.note.list")
        
        return listTemplate
    }
    
    private func getRandomMusicListTemplate(with dataStore: PlaylistDataStore) -> CPListTemplate {
        // Create or reuse the view model
        if randomMusicViewModel == nil {
            randomMusicViewModel = SongsViewModel(storage: dataStore)
            randomMusicViewModel?.handleGetRandomSongs()
        }
        
        guard let viewModel = randomMusicViewModel else {
            return CPListTemplate(title: "Random Music", sections: [])
        }
        
        // Create action buttons as list items at the top
        let playButton = CPListItem(text: "▶️ Play All", detailText: "Play the current random playlist")
        playButton.handler = { [weak self] _, completion in
            self?.randomMusicViewModel?.play()
            completion()
        }
        
        let refreshButton = CPListItem(text: "🔄 Refresh", detailText: "Generate new random playlist")
        refreshButton.handler = { [weak self] _, completion in
            self?.refreshRandomPlaylist(with: dataStore)
            completion()
        }
        
        // Create sections - buttons section first, then songs
        let buttonSection = CPListSection(items: [playButton, refreshButton])
        
        let songItems = viewModel.items.map { song in
            let item = CPListItem(text: song.trackName, detailText: song.artistName)
            item.handler = { _, completion in
                // Handle song selection
                // viewModel.playSong(song)
                completion()
            }
            return item
        }
        
        let songsSection = CPListSection(items: songItems, header: "Songs", sectionIndexTitle: nil)
        
        let listTemplate = CPListTemplate(title: "Random Music", sections: [buttonSection, songsSection])
        listTemplate.tabTitle = "Random Music"
        listTemplate.tabImage = UIImage(systemName: "shuffle")
        
        self.randomMusicListTemplate = listTemplate
        
        return listTemplate
    }

    private func setupAndShowTabBar(with dataStore: PlaylistDataStore) async {
        let listTemplate = getCategoryListTemplate(with: dataStore)
        let randomMusicTemplate = getRandomMusicListTemplate(with: dataStore)
        
        self.categoryListTemplate = listTemplate
        let tabBar = CPTabBarTemplate(templates: [listTemplate, randomMusicTemplate])
        self.tabBarTemplate = tabBar
        interfaceController?.setRootTemplate(tabBar, animated: true) { success, error in
            if let error = error {
                print("Failed to set root template: \(error)")
            }
        }
    }

    private func refreshRandomPlaylist(with dataStore: PlaylistDataStore) {
        // Regenerate the random playlist
        randomMusicViewModel?.handleGetRandomSongs()
        
        // Update the UI with new songs
        guard let viewModel = randomMusicViewModel else { return }
        
        // Recreate the button items
        let playButton = CPListItem(text: "▶️ Play All", detailText: "Play the current random playlist")
        playButton.handler = { [weak self] _, completion in
            self?.randomMusicViewModel?.play()
            completion()
        }
        
        let refreshButton = CPListItem(text: "🔄 Refresh", detailText: "Generate new random playlist")
        refreshButton.handler = { [weak self] _, completion in
            self?.refreshRandomPlaylist(with: dataStore)
            completion()
        }
        
        let buttonSection = CPListSection(items: [playButton, refreshButton])
        
        // Create the song items
        let songItems = viewModel.items.map { song in
            let item = CPListItem(text: song.trackName, detailText: song.artistName)
            item.handler = { _, completion in
                completion()
            }
            return item
        }
        
        let songsSection = CPListSection(items: songItems, header: "Songs", sectionIndexTitle: nil)
        
        // Update the existing template's sections
        randomMusicListTemplate?.updateSections([buttonSection, songsSection])
    }
    
    func reloadCategoryList(with dataStore: PlaylistDataStore) async {
        let items = dataStore.categories
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            .map { category in
                let isPlaying = category.id == self.playingCategoryId
                let displayTitle = isPlaying ? "▶️ \(category.name)" : category.name
                let detailText = isPlaying ? "Now Playing" : nil
                let item = CPListItem(text: displayTitle, detailText: detailText)
                item.handler = { [weak self] _, completion in
                    guard let self = self else { completion(); return }
                    self.playingCategoryId = category.id
                    let viewModel = SongsViewModel(category: category, storage: dataStore)
                    viewModel.play()
                    Task { await self.reloadCategoryList(with: dataStore) }
                    completion()
                }
                return item
            }
        let section = CPListSection(items: items)
        let listTemplate = CPListTemplate(title: "Click a category to play its songs", sections: [section])
        listTemplate.tabTitle = "Categories"
        listTemplate.tabImage = UIImage(systemName: "music.note.list")
        self.categoryListTemplate = listTemplate
        
        // Preserve both tabs when updating
        if let tabBar = self.tabBarTemplate {
            let randomMusicTemplate = getRandomMusicListTemplate(with: dataStore)
            tabBar.updateTemplates([listTemplate, randomMusicTemplate])
        }
    }
}
