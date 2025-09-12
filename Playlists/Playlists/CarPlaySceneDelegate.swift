import CarPlay
import UIKit

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    
    var interfaceController: CPInterfaceController?
    var playingCategoryId: UUID?
    var categoryListTemplate: CPListTemplate?
    var tabBarTemplate: CPTabBarTemplate?
    
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
    
    func makeDetailList(for category: Category) -> CPListTemplate {
        let item = CPListItem(text: "\(category.name) Song", detailText: "Example")
        item.handler = { _, completion in
            // Do something on selection
            completion()
        }
        
        let section = CPListSection(items: [item])
        return CPListTemplate(title: category.name, sections: [section])
    }
    
    // CarPlay disconnected
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                          didDisconnect interfaceController: CPInterfaceController) {
        self.interfaceController = nil
        self.categoryListTemplate = nil
        self.tabBarTemplate = nil
        self.playingCategoryId = nil
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
        let viewModel = SongsViewModel(storage: dataStore)
        viewModel.handleGetRandomSongs()
        let items = viewModel.items.map { song in
            let item = CPListItem(text: song.trackName, detailText: song.artistName)
            item.handler = { _, completion in
                // Handle song selection
                // viewModel.playSong(song)
                completion()
            }
            return item
        }
            
        let section = CPListSection(items: items)
        let listTemplate = CPListTemplate(title: "Random Music", sections: [section])
        listTemplate.tabTitle = "Random Music"
        listTemplate.tabImage = UIImage(systemName: "music.note.list")
        
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
