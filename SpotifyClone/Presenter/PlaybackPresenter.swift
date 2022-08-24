//
//  PlaybackPresenter.swift
//  SpotifyClone
//
//  Created by Saleh Masum on 15/8/2022.
//

import AVFoundation
import Foundation
import UIKit

protocol PlayerDataSource: AnyObject {
    var songName: String? { get }
    var subtitle: String? { get }
    var imageUrl: URL? { get }
}

final class PlaybackPresenter {
    
    static let shared = PlaybackPresenter()
    
    private var track: AudioTrack?
    private var tracks = [AudioTrack]()
    
    var index = 0
    
    var currentTrack: AudioTrack? {
        if let track = track, tracks.isEmpty {
            return track
        }
        else if let _ = self.playerQueue, !tracks.isEmpty {
            
            return tracks[index]
            
        }
        return nil
    }
    
    var player: AVPlayer?
    var playerQueue: AVQueuePlayer?
    var playerVC: PlayerViewController?
    
    func startPlayback(
        from viewController: UIViewController,
        track: AudioTrack
    ) {
        guard let url = URL(string: track.preview_url ?? "") else {
            return
        }
        player = AVPlayer(url: url)
        player?.volume = 0.5
        
        self.track = track
        self.tracks = []
        let vc = PlayerViewController()
        
        vc.dataSource = self
        vc.delegate = self
        
        vc.title = track.name
        viewController.present(UINavigationController(rootViewController: vc), animated: true) { [weak self] in
            self?.player?.play()
        }
        self.playerVC = vc
    }
    
    func startPlayback(
        from viewController: UIViewController,
        tracks: [AudioTrack]
    ) {
        self.tracks = tracks
        self.track = nil
        
        let items: [AVPlayerItem] = tracks.compactMap({
            guard let url = URL(string: $0.preview_url ?? "") else { return nil }
            return AVPlayerItem(url: url)
        })
        self.playerQueue = AVQueuePlayer(items: items)
        self.playerQueue?.volume = 0.5
        self.playerQueue?.play()
        
        let vc = PlayerViewController()
        vc.dataSource = self
        vc.delegate = self
        
        viewController.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
        self.playerVC = vc
    }
    
}

extension PlaybackPresenter: PlayerViewControllerDelegate {
    func didTapPlayPause() {
        if let player = self.player {
            if player.timeControlStatus == .playing {
                player.pause()
            }
            else if player.timeControlStatus == .paused {
                player.play()
            }
        }
        else if let player = self.playerQueue {
            if player.timeControlStatus == .playing {
                player.pause()
            }
            else if player.timeControlStatus == .paused {
                player.play()
            }
        }
    }
    
    func didTapForward() {
        if tracks.isEmpty {
            //Not a playlist of Album
            player?.pause()
        }else if let player = self.playerQueue {
            player.advanceToNextItem()
            index += 1
            playerVC?.refreshUI()
        }
    }
    
    func didTapBackward() {
        if tracks.isEmpty {
            //Not a playlist of Album
            player?.pause()
            player?.play()
        }else if let _ = self.playerQueue?.items().first {
            //This code is crashing need to fix this (Future work)
//            self.playerQueue?.pause()
//            self.playerQueue?.removeAllItems()
//            self.playerQueue = AVQueuePlayer(items: [firstItem])
//            self.playerQueue?.play()
//            self.playerQueue?.volume = 0.5
        }
    }
    
    func didUpdateSlider(_ value: Float) {
        player?.volume = value
    }
    
   
}

extension PlaybackPresenter: PlayerDataSource {
    
    var songName: String? {
        return currentTrack?.name
    }
    
    var subtitle: String? {
        return currentTrack?.artists.first?.name
    }
    
    var imageUrl: URL? {
        print("Images: \(currentTrack?.album?.images.first?.url ?? "")")
        return URL(string: currentTrack?.album?.images.first?.url ?? "")
    }
    
    
}
