import CarPlay
import UIKit

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    
    var interfaceController: CPInterfaceController?
    
    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController) {
            
            let dataStore = PlaylistDataStore()
            Task {
                await dataStore.load()
                guard dataStore.isLoaded else { return }
                
                let buttons = dataStore.categories.map { category in
                    let symbol = UIImage(systemName: "music.note") ?? UIImage()
                    return CPGridButton(titleVariants: [category.name], image: symbol) { [weak self] _ in
                        guard let self = self else { return }
                        let detail = self.makeDetailList(for: category)
                        self.interfaceController?.presentTemplate(detail, animated: true, completion: nil)
                    }
                }
                
                let grid = CPGridTemplate(title: "Categories", gridButtons: buttons)
                do {
                    try await interfaceController.setRootTemplate(grid, animated: true)
                } catch {
                    print("Failed to set root template: \(error)")
                }
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
}
