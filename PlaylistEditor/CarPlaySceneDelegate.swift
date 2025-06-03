//
//  CarPlaySceneDelegate.swift
//  Random Playlist Generator (iOS)
//
//  Created by Benjamin Day on 6/3/25.
//

import Foundation
import CarPlay

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didConnect interfaceController: CPInterfaceController,
                                  to window: CPWindow) {
        let listItem = CPListItem(text: "Hello CarPlay", detailText: "From your app")
        listItem.handler = { _, completion in
            print("Tapped!")
            completion()
        }

        let listTemplate = CPListTemplate(title: "Demo List", sections: [CPListSection(items: [listItem])])
        interfaceController.setRootTemplate(listTemplate, animated: true) { completed, error in
            if let error = error {
                print("Failed to set root template: \(error)")
            } else {
                print("Successfully set root template")
            }
        }
    }
}
