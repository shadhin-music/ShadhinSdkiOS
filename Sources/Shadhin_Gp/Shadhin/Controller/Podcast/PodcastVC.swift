//
//  PodcastVC.swift
//  Shadhin
//
//  Created by Rezwan on 2/10/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit

class PodcastVC: UITableViewController {
    
    var selectedTrackID = ""{
        didSet{
            self.checkIsFav()
        }
    }
    var favBtn : UIButton?{
        didSet{
            self.checkIsFav()
        }
    }
    var podcastCode: String = "PDBC"{
        didSet{
            podcastShowCode = String(podcastCode.suffix(podcastCode.count - 2)).uppercased()
            podcastType = String(podcastCode.prefix(2)).uppercased()
        }
    }
    var selectedEpisode = 0
    var selectedEpisodeID = 0
    var podcastShowCode = "BC" // or "nc"
    var podcastType = "PD"
    var selectedEpisodeCommentPaid = false
    var selectedTrack: CommonContentProtocol?
    var commingSoonView: UILabel?
    var gotData = false
    var shouldPlay = true
    var shouldShowEpisodes = false;
    var willLoadAds = false
    var cellHeightsDictionary: [IndexPath: CGFloat] = [:]
    private let downloadManager = SDDownloadManager.shared
    var currentCommentPage = 0
    var currentEpisode = -1
    var userComments : CommentsObj? = nil
    
    var headerImg: String?
    var headerTitle: String?
    var headerSubTitle: String?
    
    var headerAbout: String?{
        didSet{
            headerAbout?.stringFromHTML(completionBlock: { [weak self] _str in
                guard let this = self, let str = _str else { return }
                this.headerAboutStr = str
            })
        }
    }
    var headerAboutStr: String = ""{
        didSet{
            if(oldValue != headerAboutStr && tableView.numberOfSections > 0){
                tableView.reloadData()
            }
        }
    }
    var headerStarring: String?
    var headerProductedBy: String?
    
    var playBtn: UIButton?
    var loadMoreComments : LoadMoreActivityIndicator?
    var state: ReadMoreLessView.ReadMoreLessViewState = .collapsed
    
    var pendingRequestWorkItem0: DispatchWorkItem?
    var pendingRequestWorkItem1: DispatchWorkItem?
    var pendingRequestWorkItem2: DispatchWorkItem?
    
    var podcastModel : PodcastDetailsObj?{
        didSet{
            LoadingIndicator.stopAnimation()
            self.view.isUserInteractionEnabled = true
            if podcastModel != nil && podcastModel?.data != nil && podcastModel?.data.episodeList.count != 0 {
                if podcastModel?.data.episodeList.count ?? 0 > 1{
                    shouldShowEpisodes = true
                }else{
                    shouldShowEpisodes = false
                }
                if (commingSoonView != nil){
                    commingSoonView?.removeFromSuperview()
                    commingSoonView = nil
                }
                changeEpisode(index: 0)
                tableView.reloadData()
                gotData = true
            }
        }
    }
    
    var noInternetView : NoInternetView = NoInternetView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        let viewFooter = UIView(frame: CGRect(x: 0, y: 1, width: 1, height: (49 + (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0) + 50)))
        tableView.tableFooterView  = viewFooter
        tableView.register(CommentCell.nib, forCellReuseIdentifier: CommentCell.identifier)
        //        tableView.register(NativeSmallAdTCell.nib, forCellReuseIdentifier: NativeSmallAdTCell.identifier)
        //        tableView.register(NativeAdMaxSmall.nib, forCellReuseIdentifier: NativeAdMaxSmall.identifier)
        
        
        let refreshView0 = KRPullLoadView()
        refreshView0.delegate = self
        self.tableView.addPullLoadableView(refreshView0, type: .refresh)
        
        NotificationCenter.default.addObserver(forName: .init(rawValue: "FavDataUpdateNotify"), object: nil, queue: .main) { notificatio in
            self.checkIsFav()
        }
        
        self.view.addSubview(noInternetView)
        noInternetView.translatesAutoresizingMaskIntoConstraints = false
        noInternetView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        noInternetView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 20).isActive = true
        noInternetView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        noInternetView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive
        = true
        noInternetView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        noInternetView.isHidden = true
        
        noInternetView.retry = {[weak self] in
            guard let self = self else {return}
            if ConnectionManager.shared.isNetworkAvailable{
                self.getPodcastData()
            }
            
        }
        noInternetView.gotoDownload = {[weak self] in
            guard let self = self else {return}
            if self.checkProUser(){
                let vc = DownloadVC.instantiateNib()
                vc.selectedDownloadSeg = .init(title: ^String.Downloads.audioPodcast, type: .PodCast)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        //     ChorkiAudioAd.instance.fireEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
        if ConnectionManager.shared.isNetworkAvailable{
            if !self.gotData{
                getPodcastData()
            }
        }else{
            guard !self.gotData else {return}
            noInternetView.isHidden = false
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        shouldPlay = true
        playBtn?.setImage(UIImage(named: "ic_Play",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
        playBtn?.tag = 0
        //    loadAds()
        // InterstitialAdmob.instance.showAd(fromRootViewController: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //   InterstitialAdmob.instance.nextAdTimeReset()
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    //
    //    private func loadAds(){
    //        guard let useAdProvider = Bundle.main.object(forInfoDictionaryKey: "UseAdProvider") as? String,
    //        !ShadhinCore.instance.isUserPro else {
    //            if willLoadAds{
    //                willLoadAds = false
    //                tableView.reloadData()
    //            }
    //            return
    //        }
    //        if useAdProvider == "google"{
    //            if !willLoadAds{
    //                NativeAdLoader.shared(self.navigationController!).isReadyToLoadAds { success in
    //                    if success{
    //                        self.willLoadAds = true
    //                        self.tableView.reloadData()
    //                    }
    //                }
    //            }
    //        }else if useAdProvider == "applovin", !InterstitialAdMax.instance.sdkNotInit{
    //            if !willLoadAds{
    //                willLoadAds = true
    //                tableView.reloadData()
    //            }
    //        }
    //    }
    
    //    weak var adBannerView: GADBannerView?
    //    weak var adBannerMax: UIView?
    
    //    func shouldLoadAd(container: GADBannerView, container2:UIView){
    //        adBannerView = container
    //        adBannerMax = container2
    //        //_loadAds()
    //    }
    
    //    private func _loadAds(){
    //        guard let useAdProvider = Bundle.main.object(forInfoDictionaryKey: "UseAdProvider") as? String,
    //              !ShadhinCore.instance.isUserPro else {
    //                  removeAd()
    //                  return
    //              }
    //        if useAdProvider == "google"{
    //            loadGoogleAd()
    //        }else if useAdProvider == "applovin", !InterstitialAdMax.instance.sdkNotInit{
    //            loadApplovinAd()
    //        }else{
    //            removeAd()
    //        }
    //    }
    
    //    private func removeAd(){
    //        if !(adBannerMax?.subviews.isEmpty ?? true),
    //           let adView = adBannerMax?.subviews[0] as? MAAdView{
    //            adView.stopAutoRefresh()
    //            adView.isHidden = true
    //        }
    //        adBannerView?.isHidden = true
    //        adBannerMax?.isHidden = true
    //        if willLoadAds{
    //            willLoadAds = false
    //            tableView.reloadData()
    //        }
    //    }
    
    private func loadGoogleAd(){
        //        guard adBannerView?.tag != 1 else {return}
        //        adBannerView?.isHidden = false
        //        let screenWidth = UIScreen.main.bounds.size.width
        //        adBannerView?.adUnitID = SubscriptionService.instance.googleBannerAdId
        //        adBannerView?.rootViewController = self
        //        var size = GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(screenWidth)
        //        size.size.height = 50
        //        adBannerView?.adSize = size
        //        adBannerView?.load(GADRequest())
        //        adBannerView?.delegate = self
        //        adBannerView?.tag = 1
    }
    //
    //    private func loadApplovinAd(){
    //        if !willLoadAds{
    //            willLoadAds = true
    //            tableView.reloadData()
    //        }
    //        guard let adBannerMax = adBannerMax, adBannerMax.subviews.isEmpty else {return}
    //        let adView = MAAdView(adUnitIdentifier: AdConfig.maxBannerAdId)
    //        adView.delegate = self
    //        let height: CGFloat = 50
    //        let width: CGFloat = UIScreen.main.bounds.width
    //        adView.frame = CGRect(x: 0, y: 0, width: width, height: height)
    //        adBannerMax.addSubview(adView)
    //        adView.snp.makeConstraints { (make) in
    //            make.top.equalTo(adBannerMax.snp.top)
    //            make.left.equalTo(adBannerMax.snp.left)
    //            make.right.equalTo(adBannerMax.snp.right)
    //            make.bottom.equalTo(adBannerMax.snp.bottom)
    //        }
    //        adView.loadAd()
    //    }
    
    //    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
    //        adBannerView?.isHidden =  true
    //    }
    
    func checkIsFav(){
        if !selectedTrackID.isEmpty{
            let type : SMContentType = podcastType.uppercased() == "PD" ? .podcast : .podcastVideo
            ShadhinCore.instance.api.getAllFavoriteByType(
                type: type) { (data, error) in
                    guard let data = data else{
                        return
                    }
                    self.favBtn?.isHidden = false
                    if data.contains(where: {$0.contentID == self.selectedTrackID}) {
                        self.favBtn?.tag = 1
                        self.favBtn?.setImage(UIImage(named: "ic_favorite_a",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                    }else {
                        self.favBtn?.tag = 0
                        self.favBtn?.setImage(UIImage(named: "ic_favorite_n",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                    }
                }
        }else{
            favBtn?.isHidden = true
        }
    }
    
    
    func changeEpisode(index : Int){
        if let episode = podcastModel?.data.episodeList[index],
           let show = podcastModel?.data{
            state = .collapsed
            selectedEpisode = index
            selectedEpisodeID = episode.id
            selectedEpisodeCommentPaid = episode.isCommentPaid
            headerImg = episode.imageURL
            headerTitle = episode.name
            headerSubTitle = ""
            currentEpisode = episode.id
            currentCommentPage = 0
            userComments = nil
            pendingRequestWorkItem1?.cancel()
            pendingRequestWorkItem2?.cancel()
            
            headerAbout = episode.details
            headerStarring = show.presenter
            headerProductedBy = show.productBy
            
            //            Analytics.logEvent("sm_content_viewed",
            //                               parameters: [
            //                                "content_type"  : podcastCode.lowercased() as NSObject,
            //                                "content_id"    : String(selectedEpisodeID) as NSObject,
            //                                "user_type"     : ShadhinCore.instance.defaults.shadhinUserType.rawValue  as NSObject,
            //                                "content_name"  : episode.name.lowercased() as NSObject,
            //                                "platform"      : "ios" as NSObject
            //                               ])
            SMAnalytics.viewContent(contentName: episode.name.lowercased(), contentID: String(selectedEpisodeID), contentType: podcastCode.lowercased())
            episode.trackList = episode.trackList.sorted(by: {$0.sort > $1.sort})
            
            //pushing live to top
            for (index, item) in episode.trackList.enumerated(){
                if item.trackType == "L" || item.trackType == "LM"{
                    episode.trackList.remove(at: index)
                    episode.trackList.insert(item, at: 0)
                }
            }
            
            playBtn?.setImage(UIImage(named: "ic_Play",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
            self.shouldPlay = true
            self.playBtn?.tag = 0
            self.selectedTrackID = ""
            self.selectedTrack = nil
            
            if(episode.trackList.count > 0){
                setHeaderData(0, false)
                self.selectedTrack = episode.trackList[0]
                self.selectedTrackID = String(episode.trackList[0].id)
            }
            tableView.reloadData()
            getComments()
        }
    }
    
    @objc func reloadComments(){
        currentCommentPage = 0
        userComments = nil
        pendingRequestWorkItem1?.cancel()
        pendingRequestWorkItem2?.cancel()
        tableView.reloadData()
        getComments()
        LoadingIndicator.startAnimation(true)
    }
    
    func updateComments(data : CommentsObj){
        if userComments == nil{
            userComments = data
            if loadMoreComments == nil{
                loadMoreComments = LoadMoreActivityIndicator(scrollView: tableView, spacingFromLastCell: -(49 + (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0) + 50), spacingFromLastCellWhenLoadMoreActionStart: 60)
            }
            loadMoreComments?.stop()
        }else{
            let comments = data.data
            userComments?.data.append(contentsOf: comments)
        }
        tableView.reloadData()
    }
    
    
    
    
    
    func share(){
        if let track = podcastModel?.data.episodeList[selectedEpisode].trackList[0]{
            track.contentID  = track.albumID
            DeepLinks.createLinkTest(controller: self)
              //DeepLinks.createDeepLink(model: track, controller: self, vcType: "podcast")
        }
    }
    
    func dismiss(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func setHeaderData(_ index : Int, _ reload: Bool = true){
        if let track = podcastModel?.data.episodeList[selectedEpisode].trackList[index]{
            
            headerImg = track.imageURL
            headerTitle = track.name
            headerSubTitle = track.duration
            
            selectedTrackID = track.contentID ?? ""
            selectedTrack = track
            
            headerAbout = track.details
            headerStarring = track.starring
            if reload && tableView.numberOfSections > 0{
                tableView.reloadData()
            }
        }
    }
    
    func playMediaAtIndex (_ index : Int){
        
        guard podcastModel?.data.episodeList.count ?? 0 > selectedEpisode , let trackArray = podcastModel?.data.episodeList[selectedEpisode].trackList, index < trackArray.count else {
            return
        }
        
        if podcastType == "VD"{
            PodcastYoutubeVC.openLivePodcast(self, trackArray[index])
            //VideoPodcastVC.openLivePodcast(self, trackArray[index])
            return
        }
        
        //        #if DEBUG
        //        track.playUrl = "https://edge.mixlr.com/channel/rbhqh"
        //        track.trackType = "LM"
        //        #endif
        
        setHeaderData(index)
        
         (musicData: trackArray, songIndex: index, isRadio: false, rootModel: trackArray[index])
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.playBtn?.setImage(UIImage(named: "ic_Pause1",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
            self.tableView.reloadData()
        })
    }
    
    func addComment(){
        
//        if !ShadhinCore.instance.isUserLoggedIn{
//            //  self.showNotUserPopUp(callingVC: self)
//            return
//        }
        
//        if ShadhinCore.instance.defaults.userName.isEmpty{
//            updateNameRequired()
//            return
//        }
        
        
        
        if selectedEpisodeCommentPaid && !ShadhinCore.instance.isUserPro {
//            self.goSubscriptionTypeVC()
//            SubscriptionPopUpVC.show(self)
            NavigationHelper.shared.navigateToSubscription(from: self)
            return
        }
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        vc.contentId = selectedEpisodeID
        vc.podcastVC = self
        vc.podcastShowCode = podcastShowCode
        vc.podcastType = podcastType
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(vc, animated: true, completion: nil)
        }
        
    }
    
    func updateNameRequired(){
        AlertSlideUp.show(
            101,
            //image:#imageLiteral(resourceName: "user icon 1.pdf"),
            image:UIImage(named: "user icon 1", in: Bundle.ShadhinMusicSdk,with:nil) ?? .init(),
            tileString: "Name Required",
            msgString: "Your name seems to empty please update your name in profile to enable commenting feature",
            positiveString: "Go to profile",
            negativeString: "Close",
            buttonDelegate: self)
    }
    
    func openProfile(){
        //  let vc = MyProfileVC()
        //   self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    func viewReply(_ comment : CommentsObj.Comment, _ index : IndexPath){
        
//        if !ShadhinCore.instance.isUserLoggedIn{
//            //    self.showNotUserPopUp(callingVC: self)
//            return
//        }
        
//        if ShadhinCore.instance.defaults.userName.isEmpty{
//            updateNameRequired()
//            return
//        }
        
        if selectedEpisodeCommentPaid && !ShadhinCore.instance.isUserPro {
            self.goSubscriptionTypeVC()
           // SubscriptionPopUpVC.show(self)
            return
        }
        let vc = storyboard?.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        vc.comment = comment
        vc.indexOfComment = index
        vc.podcastVC = self
        vc.podcastShowCode = podcastShowCode
        vc.podcastType = podcastType
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(vc, animated: true, completion: nil)
        }
    }
    
    func addDeleteFav(){
        if !ShadhinCore.instance.isUserLoggedIn{
            //   self.showNotUserPopUp(callingVC: self)
            return
        }
        if favBtn?.tag == 1{
            deleteFav()
        }else{
            addFav()
        }
    }
    
    func addFav(){
        guard let track = selectedTrack else {return}
        ShadhinCore.instance.api.addOrRemoveFromFavorite(
            content: track,
            action: .add) { (err) in
                if err != nil {
                    ConnectionManager.shared.networkErrorHandle(err: err, view: self.view)
                }else {
                    self.favBtn?.tag = 1
                    self.favBtn?.setImage(UIImage(named: "ic_favorite_a",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                }
            }
    }
    
    func deleteFav(){
        guard let track = selectedTrack else {return}
        ShadhinCore.instance.api.addOrRemoveFromFavorite(
            content: track,
            action: .remove) { (err) in
                if err != nil {
                    ConnectionManager.shared.networkErrorHandle(err: err, view: self.view)
                }else {
                    self.favBtn?.tag = 0
                    self.favBtn?.setImage(UIImage(named: "ic_favorite_n",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                }
            }
    }
    
    func seeAllEpisodes(){
        guard let episodes = podcastModel?.data.episodeList else {return}
        for episode in episodes {
            episode.contentType = podcastCode
            episode.title = episode.name
            episode.contentID = "\(episode.id)"
            episode.image = episode.imageURL
        }
        let storyBoard = UIStoryboard(name: "Discover", bundle:Bundle.ShadhinMusicSdk)
        let vc = storyBoard.instantiateViewController(withIdentifier: "DiscoverMusicDetailsVC") as! DiscoverMusicDetailsVC
        vc.songDetails = episodes
        vc.designName =  ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
}

extension PodcastVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count =  podcastModel?.data.episodeList.count ?? 0
        if count > 0{
            count -= 1
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PodcastEpisodeItem.identifier, for: indexPath) as! PodcastEpisodeItem
        
        if let episode = podcastModel?.data.episodeList[indexPath.row + 1] {
            
            var imageType = "300"
            if podcastType == "VD"{
                imageType = "1280"
            }
            let imgUrl = episode.imageURL.replacingOccurrences(of: "<$size$>", with: imageType)
            cell.episodeImg.kf.indicatorType = .activity
            cell.episodeImg.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_radio"))
            cell.episodeTitle.text = episode.name
            cell.setClickListener {
                
                let vc = NoInternetPopUpVC.instantiateNib()
                vc.retry = {[weak self] in
                    guard let self = self else {return}
                    if ConnectionManager.shared.isNetworkAvailable{
                        self.selectedEpisodeID = Int(episode.code) ?? 0
                        self.getPodcastData()
                    }
                }
                vc.gotoDownload = {[weak self] in
                    guard let self = self else {return}
                    if self.checkProUser(){
                        let vc = DownloadVC.instantiateNib()
                        vc.selectedDownloadSeg = .init(title: ^String.Downloads.audioPodcast, type: .PodCast)
                        self.navigationController?.pushViewController(vc, animated: true)
                        SwiftEntryKit.dismiss()
                    }
                }
                
                if ConnectionManager.shared.isNetworkAvailable{
                    self.selectedEpisodeID = Int(episode.code) ?? 0
                    self.getPodcastData()
                }else{
                    SwiftEntryKit.display(entry: vc, using: SwiftEntryKitAttributes.bottomAlertAttributes(viewHeight: NoInternetPopUpVC.HEIGHT))
                }
            }
        }
        
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if podcastType == "VD"{
            return PodcastEpisodeItem.size_vd
        }else{
            return PodcastEpisodeItem.size_pd
        }
    }
}

//MARK: mennu delegate
extension PodcastVC: MoreMenuDelegate{
    func onDownload(content: CommonContentProtocol, type: MoreMenuType) {
        guard try! Reachability().connection != .unavailable else {return}
        
        guard checkProUser() else{
            return
        }
        //send data to firebase analytics
        AnalyticsEvents.downloadEvent(with: content.contentType, contentID: content.contentID, contentTitle: content.title)
        //send download info to server
        ShadhinApi().downloadCompletePost(model: content)
        
        guard let url = URL(string: content.playUrl?.decryptUrl() ?? "") else {
            return self.view.makeToast("Unable to get Download file Url")
        }
        
        self.view.makeToast("Downloading \(String(describing: content.title ?? ""))")
        
        let request = URLRequest(url: url)
        let _ = self.downloadManager.downloadFile(withRequest: request, onCompletion: { error, url in
            if error != nil{
                self.view.makeToast(error?.localizedDescription)
            }else{
                //self.view.makeToast("File successfully downloaded.")
                //save song
                //DatabaseContext.shared.addPodcast(content: content)
                //send download info to server
                //ShadhinApi().downloadCompletePost(model: content)
                self.tableView.reloadData()
            }
        })
        tableView.reloadData()
        
        
    }
    
    func onRemoveDownload(content: CommonContentProtocol, type: MoreMenuType) {
        DatabaseContext.shared.removePodcast(with: content.contentID  ?? "")
        if let playUrl = content.playUrl{
            SDFileUtils.removeItemFromDirectory(urlName: playUrl)
            self.view.makeToast("File Removed from Download")
        }
        tableView.reloadData()
    }
    //no need to implement this
    func onRemoveFromHistory(content: CommonContentProtocol) {
    }
    //this not call for this context
    func gotoArtist(content: CommonContentProtocol) {
    }
    //this is not call for this context
    func gotoAlbum(content: CommonContentProtocol) {
    }
    //this is not call for this context
    func addToPlaylist(content: CommonContentProtocol) {
        goAddPlaylistVC(content: content)
    }
    
    func shareMyPlaylist(content: CommonContentProtocol) {
        
    }
    
    func openQueue() {
        
    }
    
    func openSleepTimer() {
        
    }
}



extension PodcastVC : KRPullLoadViewDelegate{
    
    func pullLoadView(_ pullLoadView: KRPullLoadView, didChangeState state: KRPullLoaderState, viewType type: KRPullLoaderType) {
        
        // print("state->\(state)  type->\(type)")
        if type == .refresh{
            switch state {
            case let .loading(completionHandler):
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
                    
                    //LoadingIndicator.initLoadingIndicator(view: self.view)
                    LoadingIndicator.startAnimation(true)
                    self.view.isUserInteractionEnabled = false
                    self.getPodcastData()
                    completionHandler()
                }
                
            default: break
            }
            return
        }
        
    }
}

extension PodcastVC: ButtonDelegate{
    func buttonTaped(_ state: AlertPopUp.State, _ instanceID: Int) {
        if instanceID == 101{
            if state == .positive{
                self.openProfile()
            }
            return
        }
        if state == .positive{
            self.goSubscriptionTypeVC()
        }
    }
}

extension PodcastVC {
    private func updateFavouriteCommentServer(_ index : IndexPath, _ completion : (() -> Void)? = nil){
        guard index.row - 1 < userComments?.data.count ?? 0,
              let commentID = userComments?.data[index.row - 1].commentID,
              let commentBool = userComments?.data[index.row - 1].commentFavorite else{
            return
        }
        
        ShadhinCore.instance.api.toggleFavoriteComment(
            podcastType,
            commentID) { success in
                guard index.row - 1 < self.userComments?.data.count ?? 0, success else {return}
                self.userComments?.data[index.row - 1].commentFavorite = !commentBool
                if (self.userComments?.data[index.row - 1].commentFavorite)!{
                    self.userComments?.data[index.row - 1].totalCommentFavorite += 1
                }else{
                    self.userComments?.data[index.row - 1].totalCommentFavorite -= 1
                }
                
                self.tableView.reloadRows(at: [index], with: .automatic)
                completion?()
            }
    }
    
    private func updateLikeCommentServer(_ index : IndexPath,  _ completion : (() -> Void)? = nil){
        guard index.row - 1 < userComments?.data.count ?? 0,
              let commentID = userComments?.data[index.row - 1].commentID,
              let likeBool = userComments?.data[index.row - 1].commentLike,
              !likeBool else{
            return
        }
        ShadhinCore.instance.api.likeComment(
            podcastType,
            commentID) { success in
                guard success, index.row - 1 < self.userComments?.data.count ?? 0 else {return}
                self.userComments?.data[index.row - 1].commentLike = !likeBool
                self.tableView.reloadRows(at: [index], with: .automatic)
                completion?()
            }
    }
    
}
