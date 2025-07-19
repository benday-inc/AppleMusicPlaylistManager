import CarPlay

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    
    var interfaceController: CPInterfaceController?
    
    // CarPlay connected
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didConnect interfaceController: CPInterfaceController) {
        
        self.interfaceController = interfaceController
        
        //setInformationTemplate()
        
        let listTemplate: CPListTemplate = CarPlayHelloWorld().template
        interfaceController.setRootTemplate(listTemplate, animated: true) { completed, error in
            if let error = error {
                print("Failed to set root template: \(error)")
            } else {
                print("Successfully set root template")
            }
        }
    }
    
    // CarPlay disconnected
    private func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didDisconnect interfaceController: CPInterfaceController) {
        self.interfaceController = nil
    }
    
}


