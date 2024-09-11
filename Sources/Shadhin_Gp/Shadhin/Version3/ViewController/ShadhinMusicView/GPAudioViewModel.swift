//
//  GPAudioViewModel.swift
//  Shadhin_Gp
//
//  Created by Maruf on 4/9/24.
//

import Foundation
import UIKit

class GPAudioViewModel {
    static let shared = GPAudioViewModel()
    var trendingSongs: [GPContent] = []
    var gpMusicContents: [GPContent] = []
    var areWeInsideSDK = false
    
    var audioItems = [AudioItem]()
    var currentAudioItem: AudioItem?
    var seekTo: TimeInterval?
    
    var isTrendingPlaying: Bool = false
    var selectedIndexInCarousel: Int = 0
    var whichIndexIsPlayingInTrending: Int?
    var trendingState: PlayingState = .neverPlayed
    var trendingSongInteractionContentId: Int?
    var gpContentPlayingState: PlayingState = .neverPlayed
    
    var changeTitle: ()->Void = {}
    var changeAllButtonsToImageName: [(PlayingState, Int?)->Void] = []
     
    private init(){
        
    }
    
    func setPlayPauseImage(playPauseButton:UIButton, isPlaying: PlayingState) {
        var imageName = "stop_ic"
        switch isPlaying {
        case .neverPlayed:
            imageName = "stop_ic"
        case .playing:
            imageName = "play_pause"
        case .pause:
            imageName = "stop_ic"
        }
        playPauseButton.setImage(UIImage(named: imageName,in: Bundle.ShadhinMusicSdk,with: nil))
    }
    
    func startGPContentsAudio(index: Int) {
        if !gpMusicContents.isEmpty {
            AudioPlayer.shared.play(items: convertToAudioItems(from: gpMusicContents), startAtIndex: index)
        }
    }

    
    public func startAudio(isTrending: Bool = false){
        self.isTrendingPlaying = isTrending
        
        if let gpData = ShadhinCore.instance.defaults.gpExploreMusicList {
            if isTrending {
                let gpContents = getTrendingHits(from: gpData)
                AudioPlayer.shared.play(items: convertToAudioItems(from: gpContents), startAtIndex: 0)
            } else {
                let gpContents = getAllContents(from: gpData)
                AudioPlayer.shared.play(items: convertToAudioItems(from: gpContents), startAtIndex: selectedIndexInCarousel)
            }
            
        }
    }
    
    public func playAudio() {
        AudioPlayer.shared.resume()
    }
    
    public func pauseAudio() {
        AudioPlayer.shared.pause()
    }
    
    func getAllContents(from model: GPExploreMusicModel) -> [GPContent] {
        var allContents: [GPContent] = []
        
        // Safely unwrap the data property
        guard let patches = model.data else {
            return allContents
        }
        
        if let contents = patches.first?.contents {
            allContents.append(contentsOf: contents)
        }
        
        return allContents
    }
    
    func getTrendingHits(from model: GPExploreMusicModel) -> [GPContent] {
        var allContents: [GPContent] = []
        
        // Safely unwrap the data property
        guard let patches = model.data else {
            return allContents
        }
        
        if let contents = patches.last?.contents {
            allContents.append(contentsOf: contents)
        }
        
        return allContents
    }
    
    func convertToAudioItems(from gpContents: [GPContent]) -> [AudioItem] {
        return gpContents.compactMap { gpContent in
            // Extract the streaming URL, if available
            var url: URL? = nil
            if let streamingUrlStr = gpContent.streamingUrl, !streamingUrlStr.isEmpty {
                url = URL(string: streamingUrlStr)
            }
            
            // Initialize the AudioItem with the high-quality sound URL
            let audioItem = AudioItem(highQualitySoundURL: url)
            
            // Set additional properties
            audioItem?.contentId = gpContent.contentId.map { String($0) }
            audioItem?.contentType = gpContent.contentType
            audioItem?.trackType = gpContent.track?.trackType
            audioItem?.title = gpContent.titleEn
            audioItem?.artist = gpContent.artists?.first?.name
            audioItem?.urlKey = gpContent.streamingUrl
            
            if let imgUrl = gpContent.imageUrl?.replacingOccurrences(of: "<$size$>", with: "300"),
               let artworkUrl = URL(string: imgUrl) {
                // Assume KingfisherManager is available to download the image
                KingfisherManager.shared.downloader.downloadImage(with: artworkUrl) { result in
                    if case let .success(value) = result {
                        audioItem?.artworkImage = value.image
                    }
                }
            }
            
            return audioItem
        }
    }
}
