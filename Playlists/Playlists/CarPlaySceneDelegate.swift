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
        let dataStore = PlaylistDataStore()
        Task {
            await dataStore.load()
            guard dataStore.isLoaded else { return }
            await setupAndShowTabBar(with: dataStore)
        }
    }
    
    private func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                          didDisconnect interfaceController: CPInterfaceController) {
        self.interfaceController = nil
    }
    
    func makeDetailList(for category: Category) -> CPListTemplate {
        let item = CPListItem(text: "\(category.name) Song", detailText: "Example")
        item.handler = { _, completion in
            completion()
        }
        let section = CPListSection(items: [item])
        return CPListTemplate(title: category.name, sections: [section])
    }
    
    private func makeCategoryListTemplate(with dataStore: PlaylistDataStore) -> CPListTemplate {
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
    
    private func setupAndShowTabBar(with dataStore: PlaylistDataStore) async {
        let categoriesTemplate = makeCategoryListTemplate(with: dataStore)
        self.categoryListTemplate = categoriesTemplate
        let tabBar = CPTabBarTemplate(templates: [categoriesTemplate])
        self.tabBarTemplate = tabBar
        interfaceController?.setRootTemplate(tabBar, animated: true) { success, error in
            if let error = error {
                print("Failed to set root template: \(error)")
            }
        }
    }
    
    func reloadCategoryList(with dataStore: PlaylistDataStore) async {
        let newListTemplate = makeCategoryListTemplate(with: dataStore)
        self.categoryListTemplate = newListTemplate
        if let tabBar = self.tabBarTemplate {
            tabBar.updateTemplates([newListTemplate])
            interfaceController?.setRootTemplate(tabBar, animated: true) { success, error in
                if let error = error {
                    print("Failed to set root template: \(error)")
                }
            }
        }
    }
}
