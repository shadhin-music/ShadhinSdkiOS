//
//  ShadhinMusicView.swift
//  Shadhin_Gp
//
//  Created by Maruf on 1/8/24.
//


import UIKit
import ShadhinGPObjec

@IBDesignable
public class ShadhinMusicView: UIView {
    private var gradientLayer : CAGradientLayer!
    @IBOutlet weak var visualEffect: UIVisualEffectView!
    @IBOutlet weak var artistLbl: UILabel!
    @IBOutlet weak var songLbl: UILabel!
    @IBOutlet weak var playDurationLbl: UILabel!
    @IBOutlet weak var trackDuration: UILabel!
    private var exploreMusicData: GPExploreMusicModel?
    
    let viewModel = GPAudioViewModel.shared
    
    @IBOutlet weak var iCarouselLeftConst: NSLayoutConstraint!
    
    @IBOutlet weak var blurImage: UIImageView!
    @IBOutlet weak var gpPlayerSlider: UISlider!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var exploreMoreView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var seeAllBtn: UIView!
    @IBOutlet weak var gpCaroselMusicView: iCarousel!
    var onClick : (GPExploreMusicModel)-> Void = {_ in}
    var isFspagerDirection = false
    private var pathData: GPPatchData?
    @IBOutlet weak var mainViewBg: UIView!
    var view: UIView!
    var isPlaying: PlayingState = .neverPlayed
    var accessToken: String?
    var vc: UIViewController?
    
    public var goToSdk: (String)->Void = {_ in}
    
    public var gpDeletegate: ShadhinMusicViewDelegate? = nil
    
    public override  func awakeFromNib() {
        seeAllBtnSetup()
        nibSetup()
        fetchDataFromGpExploreMusic()
        viewModel.setPlayPauseImage(playPauseButton: playPauseButton, isPlaying: isPlaying)
        seeAllBtn.setClickListener {
            self.clickListenerForMsisdn()
        }
        exploreMoreView.setClickListener {
            self.clickListenerForMsisdn()
        }
        viewModel.changeTitle = changeTrendingTitle
        viewModel.changeAllButtonsToImageName.append(setButtonImage)
        
        gradientSetup()
    }
    
    func gradientSetup(){
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            
            UIColor(red: 1, green: 1, blue: 1, alpha: 0).cgColor,
            
            UIColor(red: 0.081, green: 0.317, blue: 0.488, alpha: 1).cgColor
            
        ]
        
        gradientLayer.locations = [0, 1]
        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.25)
        
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.78)
        
        //gradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0))
        
        //self.view.layer.insertSublayer(gradientLayer, at: 0)
        self.visualEffect.contentView.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
    func clickListenerForMsisdn() {
        if let accessToken = self.accessToken, let vc = self.vc {
            ShadhinGP.shared.gotoShadhinMusic(parentVC: vc, accesToken: accessToken)
        } else {
            self.gpDeletegate?.gotoShadhinSDK(completionHandler: { vc, accessToken in
                self.vc = vc
                self.accessToken = accessToken
                ShadhinGP.shared.gotoShadhinMusic(parentVC: vc, accesToken: accessToken)
            })
        }
    }

    
    public override func willMove(toWindow newWindow: UIWindow?) {
        if !viewModel.areWeInsideSDK {
            setUpViewIfComingBackFromAPlayerInSDK()
            if viewModel.gpMusicContents.isEmpty {
                fetchDataFromGpExploreMusic()
            }
        }
    }
    
    var isActiveInWindow: Bool {
        guard let window = self.window else {
            return false
        }
        
        return !self.isHidden && self.alpha > 0 && self.isUserInteractionEnabled && window.bounds.intersects(self.convert(self.bounds, to: window))
    }
    
    private func setUpViewIfComingBackFromAPlayerInSDK() {
        // fix music view UI only since music is playing already
        AudioPlayer.shared.delegate = self
        viewModel.gpMusicContents = viewModel.audioItems.map({$0.toGpContent()})
        gpCaroselMusicView.reloadData()
        
        let index = viewModel.audioItems.firstIndex(where: {$0.contentId == AudioPlayer.shared.currentItem?.contentId})
        
        if let index {
            viewModel.selectedIndexInCarousel = index
            setArtistLbl(index: index)
            gpCaroselMusicView.scrollToItem(at: index, animated: false)
            
            if AudioPlayer.shared.state.isPlaying {
                isPlaying = .playing
            } else {
                isPlaying = .pause
            }
            viewModel.setPlayPauseImage(playPauseButton: playPauseButton, isPlaying: isPlaying)
        }
    }

    func setButtonImage(playingState: PlayingState, contentId: Int?) {
        viewModel.setPlayPauseImage(playPauseButton: playPauseButton, isPlaying: playingState)
    }
  
    
    @IBAction func nextTapped(_ sender: Any) {

        //AudioPlayer.shared.next()
        goToNextItem()
    }
    
    @IBAction func previousTapped(_ sender: Any) {
        //AudioPlayer.shared.previous()
        goToPreviousItem()
    }
    
    @IBAction func playPauseAction(_ sender: Any) {
        if let _ = self.accessToken, let _ = self.vc {
            playPauseActionHandler()
        } else {
            self.gpDeletegate?.gotoShadhinSDK(completionHandler: { vc, accessToken in
                self.vc = vc
                self.accessToken = accessToken
                
                DispatchQueue.main.async {
                    self.playPauseActionHandler()
                }
               
            })
        }
    }
    
    func playPauseActionHandler() {
        if viewModel.gpMusicContents.count > 0 {
            viewModel.whichIndexIsPlayingInTrending = viewModel.trendingSongs.firstIndex(where: {$0.contentId == viewModel.gpMusicContents[viewModel.selectedIndexInCarousel].contentId})
            
            switch isPlaying {
            case .neverPlayed:
                viewModel.startAudio()
                isPlaying = .playing
            case .playing:
                viewModel.pauseAudio()
                isPlaying = .pause
            case .pause:
                viewModel.playAudio()
                isPlaying = .playing
            }
            
            viewModel.setPlayPauseImage(playPauseButton: playPauseButton, isPlaying: isPlaying)
            
            if viewModel.whichIndexIsPlayingInTrending != nil {
                viewModel.trendingState = isPlaying
                collectionView.reloadData()
            }
            
            rememberDataToPlayAgainInSDK()
            
        }
    }
    
    func rememberDataToPlayAgainInSDK() {
        viewModel.trendingSongInteractionContentId = viewModel.trendingSongs.first(where: {$0.contentId == viewModel.gpMusicContents[viewModel.selectedIndexInCarousel].contentId})?.contentId
        viewModel.goContentPlayingState = isPlaying
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setArtistLbl(index: Int) {
        guard viewModel.gpMusicContents.count > index else{return}
        viewModel.selectedIndexInCarousel = index
        artistLbl.text = viewModel.gpMusicContents[index].artists?.compactMap({$0.name}).joined(separator: ", ")
        songLbl.text = viewModel.gpMusicContents[index].titleEn
    }
    
    func changeTrendingTitle() {
        if let index = viewModel.whichIndexIsPlayingInTrending {
            artistLbl.text = viewModel.trendingSongs[index].artists?.compactMap({$0.name}).joined(separator: ", ")
            songLbl.text = viewModel.trendingSongs[index].titleEn ?? viewModel.gpMusicContents[index].titleBn
        }
    }

    private func fetchDataFromGpExploreMusic() {
        if ConnectionManager.shared.isNetworkAvailable {
            self.vc?.view.lock()
            ShadhinCore.instance.api.getHomeGpExplorePatchItem { [weak self] response in
                guard let self = self else {return}
                switch response {
                case .success(let successData):
                    // Save the data in the property
                    ShadhinCore.instance.defaults.gpExploreMusicList = successData
                    self.viewModel.gpMusicContents = self.viewModel.getAllContents(from: successData)
                    setArtistLbl(index: 0)
                    self.viewModel.trendingSongs = self.viewModel.getTrendingHits(from: successData)
                    self.gpCaroselMusicView.reloadData()
                    self.collectionView.reloadData()
                    // Update your UI or perform further actions with the saved data
                case .failure(let error):
                    // Handle the error
                    print("API call failed with error: \(error)")
                }
                self.vc?.view.unlock()
            }
        } else {
            self.vc?.view.lock()
            // Retrieve data from cache if network is unavailable
            if let cachedData = ShadhinCore.instance.defaults.gpExploreMusicList {
                self.exploreMusicData = cachedData
                setArtistLbl(index: 0)
                self.viewModel.gpMusicContents = self.viewModel.getAllContents(from: cachedData)
                self.viewModel.trendingSongs = self.viewModel.getTrendingHits(from: cachedData)
                self.collectionView.reloadData()
                print("Loaded data from cache: \(String(describing: self.exploreMusicData))")
                
                // Reload the UI
                self.gpCaroselMusicView.reloadData()
                self.vc?.view.unlock()
            } else {
                print("No cached data available")
            }
        }
    }
    
    private func nibSetup() {
        backgroundColor = .clear
        view = loadViewFromNib()
        view.frame = bounds
        view.translatesAutoresizingMaskIntoConstraints = true
        mainViewShadowSetup()
        viewSetupMusicCatagoryList()
        recommendedCellSetup()
        // seeAllBtnSetup()
        addSubview(view)
    }
    
    func seeAllBtnSetup() {
        //  addSubview(seeAllBtn)
    }
    
    private func viewSetupMusicCatagoryList() {
        gpCaroselMusicView.contentMode  = .scaleAspectFill
        gpCaroselMusicView.type = .rotary
        gpCaroselMusicView.dataSource = self
        gpCaroselMusicView.delegate = self
        gpCaroselMusicView.reloadData() // Ens
        AudioPlayer.shared.delegate = self
        
    }
    
    private func recommendedCellSetup() {
        collectionView.register(TrendinghitsCell.nib, forCellWithReuseIdentifier: TrendinghitsCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private  func mainViewShadowSetup() {
        mainViewBg.layer.masksToBounds = false
        mainViewBg.layer.cornerRadius = 15
        mainViewBg.layer.shadowColor = UIColor.black.cgColor
        mainViewBg.layer.shadowOffset = CGSize(width: 3, height: 3)
        mainViewBg.layer.shadowOpacity = 0.5
        mainViewBg.layer.shadowRadius = 5
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return nibView
    }
    
    func goToNextItem() {
        let currentIndex = gpCaroselMusicView.currentItemIndex
        let nextIndex = (currentIndex + 1) % gpCaroselMusicView.numberOfItems // Wrap around
        gpCaroselMusicView.scrollToItem(at: nextIndex, animated: true)
        artistLbl.text = viewModel.gpMusicContents[nextIndex].artists?.compactMap({$0.name}).joined(separator: ", ")
        songLbl.text = viewModel.gpMusicContents[nextIndex].titleEn ?? viewModel.gpMusicContents[nextIndex].titleBn
    }

    func goToPreviousItem() {
        let currentIndex = gpCaroselMusicView.currentItemIndex
        let previousIndex = (currentIndex - 1 + gpCaroselMusicView.numberOfItems) % gpCaroselMusicView.numberOfItems // Wrap around
        gpCaroselMusicView.scrollToItem(at: previousIndex, animated: true)
        artistLbl.text = viewModel.gpMusicContents[previousIndex].artists?.compactMap({$0.name}).joined(separator: ", ")
        songLbl.text = viewModel.gpMusicContents[previousIndex].titleEn ?? viewModel.gpMusicContents[previousIndex].titleBn
    }

    func formatTimeToMinutesAndSeconds(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    @IBAction func playerSliderAction(_ sender: UISlider) {
        MusicPlayerV3.shared
        let value = Float(MusicPlayerV3.audioPlayer.currentItemDuration ?? 1) * sender.value
        MusicPlayerV3.audioPlayer.seek(to: TimeInterval(value))
    }
    
}
extension ShadhinMusicView: iCarouselDataSource, iCarouselDelegate {
    public func numberOfItems(in carousel: iCarousel) -> Int {
        return viewModel.gpMusicContents.count
    }
    
    public func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var itemView: UIImageView
        if let view = view as? UIImageView {
            itemView = view
        } else {
            itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: 116, height: 116))
            itemView.contentMode = .scaleAspectFill
            itemView.cornerRadius = 16
            itemView.clipsToBounds = true
        }
        
        // Assuming you have an array of URLs
        let urlString = viewModel.gpMusicContents[index].imageUrl?.image300 ?? "" // Replace imageURLs with your actual array
        if let url = URL(string: urlString) {
            itemView.kf.setImage(with: url)
        }
        
        return itemView
        
        
    }
    
    public func carousel(_ carousel: iCarousel, itemTransformForOffset offset: CGFloat, baseTransform: CATransform3D) -> CATransform3D {
        // Define scaling factors for the non-focused items
        let scaleFactor: CGFloat = 0.75
        
        // Calculate the absolute offset from the center
        let distanceFromCenter = abs(offset)
        
        // If the item is not focused, scale it down
        let scale = max(scaleFactor, 1 - distanceFromCenter * 0.25)
        
        // Apply the scaling to the transform
        let transform = CATransform3DScale(baseTransform, scale, scale, 1)
        
        return transform
    }
    
    public func carouselDidEndScrollingAnimation(_ carousel: iCarousel) {
        let newIndex = carousel.currentItemIndex

        // Check if the selected index has changed
        if viewModel.selectedIndexInCarousel != newIndex {
            viewModel.selectedIndexInCarousel = newIndex
            
            // Ensure the index is within bounds before attempting to access the array
            if isPlaying == .playing, viewModel.gpMusicContents.indices.contains(newIndex) {
                if let audioItem = viewModel.gpMusicContents[newIndex].convertToAudioItem() {
                    AudioPlayer.shared.play(item: audioItem)
                    isPlaying = .playing
                    viewModel.setPlayPauseImage(playPauseButton: playPauseButton, isPlaying: .playing)
                    rememberDataToPlayAgainInSDK()
                }
            }
            
        }
    }
}


extension ShadhinMusicView : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.trendingSongs.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item  = viewModel.trendingSongs[indexPath.item]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrendinghitsCell.identifier, for: indexPath) as? TrendinghitsCell else{
            fatalError()
        }
        cell.shadhinMusicView = self
        
        cell.audioItem = item.convertToAudioItem()
        cell.currentContent = item
        cell.index = indexPath.item
        cell.isPlaying = .neverPlayed
        if cell.audioItem?.contentId == String(viewModel.trendingSongInteractionContentId ?? 0) {
            cell.isPlaying = viewModel.trendingState
        }
        
        cell.dataBind(img:item.imageUrl ?? "", title: (item.titleEn ?? item.titleBn) ?? "")
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 300, height: 40)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension ShadhinMusicView: AudioPlayerDelegate {
    public func audioPlayer(_ audioPlayer: AudioPlayer, didFindDuration duration: TimeInterval, for item: AudioItem) {
        self.trackDuration.text = formatSecondsToString(duration)
        if !viewModel.isTrendingPlaying {
            if let itemIndex = viewModel.gpMusicContents.firstIndex(where: {String($0.contentId ?? 0) == item.contentId}){
                gpCaroselMusicView.scrollToItem(at: itemIndex, animated: true)
                artistLbl.text = viewModel.gpMusicContents[itemIndex].artists?.compactMap({$0.name}).joined(separator: ", ")
                songLbl.text = viewModel.gpMusicContents[itemIndex].titleEn
            }
        }
    }
    
    public func audioPlayer(_ audioPlayer: AudioPlayer, didUpdateProgressionTo time: TimeInterval, percentageRead: Float){
        playDurationLbl.text = formatTimeToMinutesAndSeconds(time)
        gpPlayerSlider.value = Float(percentageRead/100)
        viewModel.seekTo = time
    }
}

enum PlayingState {
    case neverPlayed
    case playing
    case pause
}

public protocol ShadhinMusicViewDelegate {
    func gotoShadhinSDK(completionHandler: @escaping (UIViewController, String)-> Void)
}

