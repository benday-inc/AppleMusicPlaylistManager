//
//  CarPlaySceneDelegate.swift
//  Random Playlist Generator (iOS)
//
//  Created by Benjamin Day on 6/3/25.
//

import Foundation
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

class CarPlayHelloWorld {
    var template: CPListTemplate {
        return CPListTemplate(title: "Hello world", sections: [self.section])
    }
    
    var items: [CPListItem] {
        return [CPListItem(text:"Hello world", detailText: "The world of CarPlay", image: UIImage(systemName: "globe"))]
    }
    
    private var section: CPListSection {
        return CPListSection(items: items)
    }
}
