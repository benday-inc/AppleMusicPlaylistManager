import CarPlay
import UIKit

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    // MARK: - Properties
    var interfaceController: CPInterfaceController?
    var playingCategoryId: UUID?
    var categoryListTemplate: CPListTemplate?
    
    // MARK: - Lifecycle
    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        let dataStore = PlaylistDataStore()
        Task {
            await dataStore.load()
            guard dataStore.isLoaded else { return }
            await reloadCategoryList(with: dataStore)
        }
    }
    
    private func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                          didDisconnect interfaceController: CPInterfaceController) {
        self.interfaceController = nil
    }
    
    // MARK: - UI Helpers
    private func makeListItem(for category: Category, dataStore: PlaylistDataStore) -> CPListItem {
        let isPlaying = category.id == self.playingCategoryId
        let displayTitle = isPlaying ? "▶️ \(category.name)" : category.name
        let detailText = isPlaying ? "Now Playing" : nil
        let item = CPListItem(text: displayTitle, detailText: detailText)
        item.handler = { [weak self] _, completion in
            self?.handleCategorySelection(category: category, dataStore: dataStore, completion: completion)
        }
        return item
    }
    
    private func makeCategoryListTemplate(with categories: [Category], dataStore: PlaylistDataStore) -> CPListTemplate {
        let items = categories
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            .map { makeListItem(for: $0, dataStore: dataStore) }
        let section = CPListSection(items: items)
        return CPListTemplate(title: "Click a category to play its songs", sections: [section])
    }
    
    // MARK: - Actions
    private func handleCategorySelection(category: Category, dataStore: PlaylistDataStore, completion: @escaping () -> Void) {
        self.playingCategoryId = category.id
        let viewModel = SongsViewModel(category: category, storage: dataStore)
        viewModel.play()
        Task { await self.reloadCategoryList(with: dataStore) }
        completion()
    }
    
    // MARK: - Public Methods
    func reloadCategoryList(with dataStore: PlaylistDataStore) async {
        let listTemplate = makeCategoryListTemplate(with: dataStore.categories, dataStore: dataStore)
        self.categoryListTemplate = listTemplate
        do {
            try await interfaceController?.setRootTemplate(listTemplate, animated: true)
        } catch {
            print("Failed to set root template: \(error)")
        }
    }
    
    // MARK: - Detail List (Example)
    func makeDetailList(for category: Category) -> CPListTemplate {
        let item = CPListItem(text: "\(category.name) Song", detailText: "Example")
        item.handler = { _, completion in
            // Do something on selection
            completion()
        }
        let section = CPListSection(items: [item])
        return CPListTemplate(title: category.name, sections: [section])
    }
}
