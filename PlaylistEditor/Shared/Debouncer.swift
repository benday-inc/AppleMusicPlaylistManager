//
//  Debouncer.swift
//  Random Playlist Generator
//
//  Created by Benjamin Day on 4/23/25.
//


import SwiftUI
import MusicKit
import MediaPlayer
import Combine

class Debouncer: ObservableObject {
    let input = PassthroughSubject<String, Never>()
    private var cancellable: AnyCancellable?

    func start(onDebounced: @escaping (String) -> Void) {
        cancellable = input
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { value in
                onDebounced(value)
            }
    }
}
