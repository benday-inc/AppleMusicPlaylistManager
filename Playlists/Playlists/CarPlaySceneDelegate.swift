import CarPlay
import UIKit

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    
    var interfaceController: CPInterfaceController?
    var playingCategoryId: UUID?
    var categoryGridTemplate: CPGridTemplate?
    
    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController) {
            
            self.interfaceController = interfaceController
            let dataStore = PlaylistDataStore()
            Task {
                await dataStore.load()
                guard dataStore.isLoaded else { return }
                
                await reloadCategoryGrid(with: dataStore)
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
    private func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                          didDisconnect interfaceController: CPInterfaceController) {
        self.interfaceController = nil
    }

    func reloadCategoryGrid(with dataStore: PlaylistDataStore) async {
        let buttons = dataStore.categories.map { category in
            let config = UIImage.SymbolConfiguration(pointSize: 36, weight: .semibold, scale: .large)
            let isPlaying = category.id == self.playingCategoryId
            let symbolName = isPlaying ? "music.note.list" : "music.note"
            let symbol = UIImage(systemName: symbolName, withConfiguration: config)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
            let displayTitle = isPlaying ? "▶️ \(category.name)" : category.name
            return CPGridButton(titleVariants: [displayTitle], image: symbol) { [weak self] _ in
                guard let self = self else { return }
                self.playingCategoryId = category.id
                let viewModel = SongsViewModel(category: category, storage: dataStore)
                viewModel.play()
                Task { await self.reloadCategoryGrid(with: dataStore) }
            }
        }

        if let grid = self.categoryGridTemplate {
            grid.updateGridButtons(buttons)
        } else {
            let grid = CPGridTemplate(title: "Categories", gridButtons: buttons)
            self.categoryGridTemplate = grid
            do {
                try await interfaceController?.setRootTemplate(grid, animated: true)
            } catch {
                print("Failed to set root template: \(error)")
            }
        }
    }
}
