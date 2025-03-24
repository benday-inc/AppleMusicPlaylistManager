import SwiftUI
import AVFoundation
import MediaPlayer

class MusicPlayer: ObservableObject {
    private var player = AVQueuePlayer()
    private var playerLooper: AVPlayerLooper?

    @Published var isPlaying = false

    func playTracks(_ items: [MPMediaItem]) {
        let playerItems = items.compactMap { item -> AVPlayerItem? in
            guard let url = item.assetURL else { return nil }
            return AVPlayerItem(url: url)
        }
        
        guard !playerItems.isEmpty else { return }

        player = AVQueuePlayer(items: playerItems)
        player.play()
        isPlaying = true
        
        setupNowPlaying(items.first!)
    }

    func pause() {
        player.pause()
        isPlaying = false
    }

    private func setupNowPlaying(_ item: MPMediaItem) {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = item.title ?? "Unknown"
        nowPlayingInfo[MPMediaItemPropertyArtist] = item.artist ?? "Unknown"
        
        if let artwork = item.artwork?.image(at: CGSize(width: 400, height: 400)) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: artwork.size) { _ in artwork }
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
