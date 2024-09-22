//
//  MusicArtistListVC.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/16/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

class MusicArtistListVC: UIViewController {
    var history_data: CommonContentProtocol?
    private var artistSongs = [CommonContent_V2]()
    private var favs = "-1"
    private var artistImg = ""
    private var artistFollow = ""
    private var artistFavImg = ""
    private var monthlyListeners = 0
    
    var discoverModel: CommonContentProtocol!
    
    @IBOutlet weak var noInternetView: NoInternetView!
    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var adBannerView: GADBannerView!
    @IBOutlet weak var adBannerMax: UIView!
    
    private var artistSummary = ""
    private var expandedCells = Set<Int>()
    
    var artistList : [CommonContent_V0]?
    var selectedArtistList : Int = 0
    var favPlaylistID = ""
    var artistID = ""
    var state: ReadMoreLessView.ReadMoreLessViewState = .collapsed
    var willLoadAds = false

    private let downloadManager = SDDownloadManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customBGColor()
        tableView.contentInsetAdjustmentBehavior = .never
//        tableView.register(NativeSmallAdTCell.nib, forCellReuseIdentifier: NativeSmallAdTCell.identifier)
//        tableView.register(NativeAdMaxSmall.nib, forCellReuseIdentifier: NativeAdMaxSmall.identifier)
        
        noInternetView.isHidden = true 
        noInternetView.retry = {[weak self] in
            guard let self  = self else { return}
            if ConnectionManager.shared.isNetworkAvailable{
                getDataFromServer()
            }
        }
        
        noInternetView.gotoDownload = {[weak self] in
            guard let self  = self else { return}
            if self.checkProUser(){
                let vc = DownloadVC.instantiateNib()
                vc.selectedDownloadSeg = .init(title: ^String.Downloads.artist, type: .Artist)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        if ConnectionManager.shared.isNetworkAvailable{
            getDataFromServer()
        }else{
            tableView.isHidden = true
            noInternetView.isHidden = false
        }
        
    }
    
    private func getDataFromServer() {
        artistID = discoverModel.artistID != "" && discoverModel.artistID != nil ? discoverModel.artistID! : discoverModel.contentID ?? ""
        if try! Reachability().connection == .unavailable{
            self.artistSongs = DatabaseContext.shared.getSonngsByArtist(where: artistID)
            self.tableView.reloadData()
            return
        }
        
        ShadhinCore.instance.api.getSongsBy(artistID: artistID.trimmingCharacters(in: .whitespacesAndNewlines)) { (artistModel, err) in
            if err != nil {
                ConnectionManager.shared.networkErrorHandle(err: err, view: self.view)
            }else {
                if self.discoverModel.artist == nil || self.discoverModel.artist?.isEmpty ?? true{
                    self.discoverModel.artist = artistModel?.data[0].artist
                }
                self.favs = artistModel?.fav ?? "-1"
                self.artistSongs = artistModel?.data ?? []
                self.artistImg = artistModel?.image ?? ""
                self.artistFollow = artistModel?.follow ?? ""
                if let monthlyListner = artistModel?.MonthlyListener,
                    let mlInt = Int(monthlyListner){
                    self.monthlyListeners = mlInt
                }
                
                self.tableView.isHidden = false
                self.noInternetView.isHidden = true
                SwiftEntryKit.dismiss()
                
                if self.artistSongs.count > 0{
                    self.artistSongs = self.artistSongs.sorted(by: {$0.playCount! > $1.playCount!})
                    weak var weakSelf = self
                    ShadhinCore.instance.api.checkContentsForRBT(self.artistSongs) { items in
                        guard let _self = weakSelf else {return}
                        for (index, song) in _self.artistSongs.enumerated(){
                            if let contentId = song.contentID,
                               items.contains(contentId){
                                _self.artistSongs[index].hasRBT = true
                            }
                        }
                        _self.tableView.reloadData()
                    }
                }
                self.getBiography()
                self.checkFavPlaylist()
                //self.getMonthlyListeners()
                self.tableView.reloadData()
                self.checkIsFollowing()
            }
        }
    }
    
    private func checkFavPlaylist(){
        ShadhinCore.instance.api.getArtistFeaturedPlaylist(artistID) { _data in
            guard let data = _data else {return}
            if data.playListID.count > 0{
                self.favPlaylistID = data.playListID
                self.artistFavImg = data.playListImage
                self.tableView.reloadData()
            }
        }
    }
    
    private func checkIsFollowing(){
        
        if !ShadhinCore.instance.isUserLoggedIn{
            self.favs = "0"
            //self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            return
        }
        ShadhinCore.instance.api.getAllFavoriteByType(
            type: .artist) { (artists, err) in
                if err != nil {
                    ConnectionManager.shared.networkErrorHandle(err: err, view: self.view)
                }else {
                    self.favs = "0"
                    if let artists = artists{
                        for artist in artists{
                            if artist.contentID == self.artistID{
                                self.favs = "1"
                            }
                        }
                    }
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                }
            }
    }
    
    
    
    private func getBiography(){
        guard let _ = self.discoverModel.artist, !artistSongs.isEmpty else{
            
            return
        }
        ShadhinCore.instance.api.getArtistBioFromLastFm(artistName: discoverModel.artist ?? "") { (summaries, err) in
            guard let summary = summaries else {
                self.artistSummary = "No biography found."
                //self.tableView.reloadRows(at: [.init(row: 0, section: 0)], with: .automatic)
                self.tableView.reloadData()
                return
            }
            DispatchQueue.main.async {
                self.artistSummary = self.subrangeArtistBiograghyFromLastFM(serverString: summary)
                self.artistSummary = self.artistSummary.count > 25 ? self.artistSummary : "No biography found."
                //self.tableView.reloadRows(at: [.init(row: 0, section: 0)], with: .automatic)
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
      //  loadAds()
        //after start download update table view for show progress
        NotificationCenter.default.addObserver(forName: .DownloadStartNotify, object: nil, queue: .main) { notificationn in
            UIView.performWithoutAnimation {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
    //    InterstitialAdmob.instance.showAd(fromRootViewController: self)
    }
//    
//    private func loadAds(){
//        guard let useAdProvider = Bundle.main.object(forInfoDictionaryKey: "UseAdProvider") as? String,
//        !ShadhinCore.instance.isUserPro else {
//            removeAd()
//            return
//        }
//        if useAdProvider == "google"{
//                  loadGoogleAd()
//        }else if useAdProvider == "applovin", !InterstitialAdMax.instance.sdkNotInit{
//            loadApplovinAd()
//        }else{
//            removeAd()
//        }
//    }
//    
//    private func removeAd(){
//        if !adBannerMax.subviews.isEmpty,
//            let adView = adBannerMax.subviews[0] as? MAAdView{
//            adView.stopAutoRefresh()
//            adView.isHidden = true
//        }
//        adBannerView.isHidden = true
//        adBannerMax.isHidden = true
//        if willLoadAds{
//            willLoadAds = false
//            tableView.reloadData()
//        }
//    }
//    
//    private func loadGoogleAd(){
////        adBannerView.isHidden = false
////        let screenWidth = UIScreen.main.bounds.size.width
////        adBannerView.adUnitID = SubscriptionService.instance.googleBannerAdId
////        adBannerView.rootViewController = self
////        var size = GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(screenWidth)
////        size.size.height = 50
////        adBannerView.adSize = size
////        adBannerView.load(GADRequest())
////        adBannerView.delegate = self
//        if !willLoadAds{
//            NativeAdLoader.shared(self.navigationController!).isReadyToLoadAds { success in
//                if success{
//                    self.willLoadAds = true
//                    self.tableView.reloadData()
//                }
//            }
//        }
//    }
    
//    private func loadApplovinAd(){
//        if !willLoadAds{
//            willLoadAds = true
//            tableView.reloadData()
//
//        }
//        guard adBannerMax.subviews.isEmpty else {return}
//        let adView = MAAdView(adUnitIdentifier: AdConfig.maxBannerAdId)
//        adView.delegate = self
//        let height: CGFloat = 50
//        let width: CGFloat = UIScreen.main.bounds.width
//        adView.frame = CGRect(x: 0, y: 0, width: width, height: height)
//        adBannerMax.addSubview(adView)
//        adView.snp.makeConstraints { [weak self] (make) in
//            guard let strongSelf = self else { return }
//            make.top.equalTo(strongSelf.adBannerMax.snp.top)
//            make.left.equalTo(strongSelf.adBannerMax.snp.left)
//            make.right.equalTo(strongSelf.adBannerMax.snp.right)
//            make.bottom.equalTo(strongSelf.adBannerMax.snp.bottom)
//        }
//        adView.loadAd()
//    }

    
    
//    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
//        adBannerView.isHidden =  true
//    }
    
    func subrangeArtistBiograghyFromLastFM(serverString: String) -> String {
        var actualString = serverString
        if let range = actualString.range(of: "<") {
            actualString.removeSubrange(range.lowerBound..<actualString.endIndex)
        }
        return actualString
    }
    
    func changeArtist(_ index : Int){
        discoverModel = artistList![index]
        selectedArtistList = index
        favPlaylistID = ""
        artistID = ""
        getDataFromServer()
        self.tableView.setContentOffset(.zero, animated: false)
    }
    
   private func shufflePlay(){
        openMusicPlayerV3(musicData: artistSongs, songIndex: 0, isRadio: false,rootModel: discoverModel)
        MusicPlayerV3.shared.turnOnShuffle()
    }
//    private func musicArtistDownload(){
//        MusicPlayerV3.shared.onDownload(content:self.discoverModel,type:MoreMenuType.Artist)
//        MusicPlayerV3.shared.checkSongsIsDownloading(index:0)
//    }
}

// MARK: - table view

extension MusicArtistListVC: UITableViewDelegate,UITableViewDataSource {
    
    func isIndexAnAd(index : Int) -> Bool{
        if !willLoadAds{
            return false
        }
        return index % 4 == 0
    }
    
    func getAdAdjustedRow(row: Int) -> Int{
        if !willLoadAds{
            return row
        }
        let n = Double(row) / 4.0
        let _n = Int(n.rounded(.up))
        let adjustedSection = row - (1 * _n)
        return adjustedSection
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if try! Reachability().connection == .unavailable{
            return 2
        }
        return (artistList == nil ? 3 : 4) + (favPlaylistID.count > 0 ? 1 :  0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 1 && favPlaylistID.count == 0) || (section == 2 && favPlaylistID.count > 0) {
            var count = artistSongs.count
            if willLoadAds{
                let adsCountDouble = Double(count) / 3.0
                let adsCountInt = Int(adsCountDouble.rounded(.up))
                count += adsCountInt
            }
            return count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var section =  indexPath.section
        if (section == 1 && favPlaylistID.count > 0){
            section =  4
        }else if (section > 1 && favPlaylistID.count > 0){
            section -= 1
        }
        
        switch section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistSongsViewCell") as! ArtistSongsViewCell
            
            cell.confifureCell(model: discoverModel,
                               index: artistSongs.count,
                               favs: self.favs,
                               artistImg: self.artistImg,
                               follow: self.artistFollow,
                               monthlyListener: monthlyListeners)
            
            cell.artistBioDescription.setText(text: self.artistSummary, state: self.state)
            cell.artistBioDescription.autoExpandCollapse = false
            cell.artistBioDescription.delegate = self
//            cell.artistBioLbl.text = self.artistSummary
//            cell.artistBioLbl.shouldTrim = !expandedCells.contains(indexPath.row)
//            cell.artistBioLbl.setNeedsUpdateTrim()
//            cell.artistBioLbl.layoutIfNeeded()
            
            cell.didTapFollowButton {

                
                if !ShadhinCore.instance.isUserLoggedIn{
                  //  self.showNotUserPopUp(callingVC: self)
                    return
                }
                
                if cell.isFollow {
                    ShadhinCore.instance.api.addOrRemoveFromFavorite(
                        content: self.discoverModel,
                        action: .remove) { (err) in
                            if err != nil {
                                ConnectionManager.shared.networkErrorHandle(err: err, view: self.view)
                            }else {
                                cell.followBtn.setTitle("Follow", for: .normal)
                                self.favs = "0"
                                self.view.makeToast("Artist removed from the following list")
                            }
                        }
                }else {
                    ShadhinCore.instance.api.addOrRemoveFromFavorite(
                        content: self.discoverModel,
                        action: .add) { (err) in
                            if err != nil {
                                ConnectionManager.shared.networkErrorHandle(err: err, view: self.view)
                            }else {
                                cell.followBtn.setTitle("Following", for: .normal)
                                self.favs = "1"
                                self.view.makeToast("You are now following the artist")
                            }
                        }
                }
                
                cell.isFollow.toggle()
            }
            
            cell.didTapBackButton {
                self.navigationController?.popViewController(animated: true)
               // self.dismiss(animated: true, completion: nil)
            }
            
            cell.didTapShareButton {
                DeepLinks.createLinkTest(controller: self)
            }
            return cell
        case 1:
//            
//            if isIndexAnAd(index: indexPath.row){
//                let useAdProvider = Bundle.main.object(forInfoDictionaryKey: "UseAdProvider") as? String
//                if useAdProvider == "google"{
//                    let cell =  tableView.dequeueReusableCell(withIdentifier: NativeSmallAdTCell.identifier, for: indexPath) as! NativeSmallAdTCell
//                    if let nav = self.navigationController, let ad = NativeAdLoader.shared(nav).getNativeAd(){
//                        cell.loadAd(nativeAd: ad)
//                    }
//                    return cell
//
//                }else if useAdProvider == "applovin"{
//                    let cell =  tableView.dequeueReusableCell(withIdentifier: NativeAdMaxSmall.identifier, for: indexPath) as! NativeAdMaxSmall
//                    cell.tableview = self.tableView
//                    return cell
//                }
//            }
            
            let adjustedRow = getAdAdjustedRow(row: indexPath.row)
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistSongsListCell") as! ArtistSongsListCell
            var item = artistSongs[adjustedRow]
            item.artistID = artistID
            cell.configureCell(model: item, true)
            
            if item.hasRBT{
                cell.rbtBtn.isHidden = false
                cell.songsDurationLbl.isHidden = true
                cell.rbtBtn.setClickListener {
                 //   CallerTunePaymentOptionsVC.setRbtOnContent(self, item)
                }
            }else{
                cell.rbtBtn.isHidden = true
                cell.songsDurationLbl.isHidden = false
            }
            
            
            cell.didThreeDotMenuTapped {
                let menu = MoreMenuVC()
                let obj = self.artistSongs[adjustedRow]
                menu.data = obj
                menu.delegate = self
                menu.menuType = .Songs
                menu.openForm = .Artist
                var height = MenuLoader.getHeightFor(vc: .Artist, type: .Songs)
                if obj.albumID == nil || obj.albumID == ""{
                    height -= 50
                }
                var attribute = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 0)
                attribute.entryBackground = .color(color: .clear)
                attribute.border = .none
                SwiftEntryKit.display(entry: menu, using: attribute)
            }
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistAlbumListCell") as! ArtistAlbumListCell
            let artistID = discoverModel.artistID != "" && discoverModel.artistID != nil ? discoverModel.artistID! : discoverModel.contentID
            cell.configureCell(contentID: artistID ?? "")
            cell.didSelectAlbumList { (content) in
                let vc = self.goAlbumVC(isFromThreeDotMenu: false, content: content)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: ArtistListCell.identifier) as! ArtistListCell
            cell.configureCell(content: artistList!, index: selectedArtistList) { (index) in
                
                
                let alert = NoInternetPopUpVC.instantiateNib()
                alert.gotoDownload = {[weak self] in
                    guard let self = self else {return}
                    if self.checkProUser(){
                        let vc = DownloadVC.instantiateNib()
                        vc.selectedDownloadSeg = .init(title: ^String.Downloads.artist, type: .Artist)
                        self.navigationController?.pushViewController(vc, animated: true)
                        SwiftEntryKit.dismiss()
                    }
                    
                }
                alert.retry = {[weak self] in
                    guard let self = self else {return}
                    if ConnectionManager.shared.isNetworkAvailable{
                        self.changeArtist(index)
                        SwiftEntryKit.dismiss()
                    }
                }
                
                if ConnectionManager.shared.isNetworkAvailable{
                    self.changeArtist(index)
                    SwiftEntryKit.dismiss()
                }else{
                    SwiftEntryKit.display(entry: alert, using: SwiftEntryKitAttributes.bottomAlertAttributes(viewHeight: NoInternetPopUpVC.HEIGHT))
                }
                
                
                
            }
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: ArtistFavCell.identifier) as! ArtistFavCell
            let imgUrl = artistFavImg.replacingOccurrences(of: "<$size$>", with: "300")
            cell.imgBg.kf.setImage(with: URL(string: imgUrl.safeUrl()))
            cell.imgMain.kf.indicatorType = .activity
            cell.imgMain.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_artist"))
            cell.artlistNameL.text = "\(self.discoverModel.artist ?? "")'s"
            return cell
        default:
            return .init()
        }
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if indexPath.section == 0 {
//            let cell = cell as! ArtistSongsViewCell
//            cell.artistBioLbl.onSizeChange = { [unowned tableView, unowned self] r in
//                let point = tableView.convert(r.bounds.origin, from: r)
//                guard let indexPath = tableView.indexPathForRow(at: point) else { return }
//                if r.shouldTrim {
//                    self.expandedCells.remove(indexPath.row)
//                } else {
//                    self.expandedCells.insert(indexPath.row)
//                }
//                tableView.reloadData()
//            }
//        }
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: true)
       
        if (indexPath.section == 1 && favPlaylistID.count == 0) || (indexPath.section == 2 && favPlaylistID.count > 0) {
            if isIndexAnAd(index: indexPath.row){
                return
            }
            tableView.deselectRow(at: indexPath, animated: true)
            let adjustedRow = getAdAdjustedRow(row: indexPath.row)
            //todo here
//#if DEBUG
//            openMusicPlayerV4(musicData: artistSongs, songIndex: adjustedRow, isRadio: false,rootModel: discoverModel)
//            return
//#endif
            openMusicPlayerV3(musicData: artistSongs, songIndex: adjustedRow, isRadio: false,rootModel: discoverModel)
        }else if (indexPath.section == 1 && favPlaylistID.count > 0){
            tableView.deselectRow(at: indexPath, animated: true)
            var temp = CommonContent_V0()
            temp.contentID = favPlaylistID
            temp.image = artistFavImg
            temp.contentType =  "p"
            temp.title = "\(self.discoverModel.artist ?? "")'s favorites"
            let vc2 = goPlaylistVC(content: temp)
            navigationController?.pushViewController(vc2, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var _section =  section
        if (section == 1 && favPlaylistID.count > 0){
            _section =  4
        }else if (section > 1 && favPlaylistID.count > 0){
            _section -= 1
        }
       
        if _section == 1{
            let newHeader = ShuffleAndDownloadView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
//            let header = HeaderWithSwitchView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:50))
            let artistID = discoverModel.artistID != "" && discoverModel.artistID != nil ? discoverModel.artistID! : discoverModel.contentID
            //check artist allready download or not
            let isDownloaded = DatabaseContext.shared.isArtistExist(for: artistID ?? "")
            let isDownloading = DatabaseContext.shared.isArtistDownloading(artistId: artistID ?? "")
            //set header titile
//            header.setTitle(with: ^String.Downloads.download,isHideSwitch: false)
//            //download all enable
//            header.isOn = isDownloaded
            
//            if DatabaseContext.shared.isArtistDownloading(artistId: artistID ?? ""){
//           header.isDownloading = true
//            }else{
//                header.isDownloading = false
//            }
            //switch change action
//            header.switchChangeHandler = { isOn in
//                if self.checkUser(){
//                    if isOn {
//                        self.downloadAllSongs()
//                    } else {
//                        self.cancellAllDownload()
//                    }
//                } else {
//                    header.isOn = false
//                }
//            }
            // download button state change
            newHeader.downloadProgress.isHidden = true
            if isDownloading {
                newHeader.downloadProgress.isHidden = false
                newHeader.downloadProgress.startAnimating()
                newHeader.downloadButton.setImage(UIImage(named: "music_v4/ic_stop"), for: .normal)
            } else if isDownloaded {
                newHeader.downloadButton.setImage(UIImage(named: "downloadComplete"), for:.normal)
            }  else {
                newHeader.downloadButton.setImage(UIImage(named: "download",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
            }
            // for shuffle button action
//            newHeader.shuffleButton.setClickListener {
//                self.shufflePlay()
//            }
            // for download button action
            if let artistId = artistID {
                newHeader.contentID = artistId
                newHeader.contentType = "A"
                newHeader.updateShuffleBtn()
            }
            //if check set button blue else white
            newHeader.shuffleButton.setClickListener {
                guard let artistId = artistID else {
                    return
                }
                //if checked remove(){update ui} else add(){update ui}
                if ShadhinCore.instance.defaults.checkShuffle(contentId:artistId,contentType:"A") {
                    ShadhinCore.instance.defaults.removeShuffle(contentId:artistId,contentType:"A")
                } else {
                    ShadhinCore.instance.defaults.addShuffle(contentId: artistId, contentType:"A")
                }
                NotificationCenter.default.post(name: .init("ShuffleListNotify"), object: nil)
            }
            newHeader.downloadButton.setClickListener {
                if self.checkProUser() {
                    if(isDownloaded || isDownloading){
                        self.cancellAllDownload()
                    } else {
                        self.downloadAllSongs() //Todo neeed to remove after test
                        newHeader.downloadProgress.isHidden = false
                        newHeader.downloadProgress.startAnimating()
                        newHeader.downloadButton.setImage(UIImage(named: "music_v4/ic_stop"), for: .normal)
                    }
                }
            }
            return newHeader
            
        } else if _section != 0 && _section != 4 {
            let view = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:50))
            let label = UILabel(frame: CGRect(x:12, y:10, width:tableView.frame.size.width, height:30))
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.text = [^String.ArtistList.albums, ^String.ArtistList.fanAlsoLike][_section - 2]
            view.addSubview(label)
            view.backgroundColor = .clear
            return view
        } else {
            return nil
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        var _section =  section
        if (section == 1 && favPlaylistID.count > 0){
            _section =  4
        }else if (section > 1 && favPlaylistID.count > 0){
            _section -= 1
        }

        return _section == 0 || _section == 4 ? CGFloat.leastNormalMagnitude : 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var _section =  indexPath.section
        if (_section == 1 && favPlaylistID.count > 0){
            _section =  4
        }else if (_section > 1 && favPlaylistID.count > 0){
            _section -= 1
        }
        switch  _section{
        case 0:
            return UITableView.automaticDimension
        case 1:
//            if isIndexAnAd(index: indexPath.row){
//                let useAdProvider = Bundle.main.object(forInfoDictionaryKey: "UseAdProvider") as? String
//                if useAdProvider == "google"{
//                    return NativeSmallAdTCell.size
//                }else if useAdProvider == "applovin"{
//                    return NativeAdMaxSmall.size
//                }else{
//                    return .leastNormalMagnitude
//                }
//            }
            return 70
        case 3 :
            return ArtistListCell.height
        case 4 :
            return ArtistFavCell.size
        default:
            return 186
        }
    }
    

    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        var _section =  indexPath.section
        if (_section == 1 && favPlaylistID.count > 0){
            _section =  4
        }else if (_section > 1 && favPlaylistID.count > 0){
            _section -= 1
        }
        switch  _section{
        case 0:
            return UITableView.automaticDimension
        case 1:
            return 70
        case 3 :
            return ArtistListCell.height
        case 4 :
            return ArtistFavCell.size
        default:
            return 186
        }
    }
}

//MARK: mennu delegate
extension MusicArtistListVC: MoreMenuDelegate{
    func openQueue() {
        
    }
    
    func onDownload(content: CommonContentProtocol, type: MoreMenuType) {
        guard try! Reachability().connection != .unavailable else {return}
        
        //check user log in or not
        //check user is subscribe or not
        guard checkProUser() else{
            return
        }
        guard let url = URL(string: content.playUrl?.decryptUrl() ?? "") else {
            return self.view.makeToast("Unable to get Download url for file")
        }
        //send data to firebase analytics
     //   AnalyticsEvents.downloadEvent(with: content.contentType, contentID: content.contentID, contentTitle: content.title)
        
        self.view.makeToast("Downloading \(String(describing: content.title ?? ""))")
        
        let request = URLRequest(url: url)
        let _ = self.downloadManager.downloadFile(withRequest: request, onCompletion: { error, url in
            if error != nil{
                self.view.makeToast(error?.localizedDescription)
            }else{
                //no need to do any thing
                //all case handle in cell
            }
        })
        tableView.reloadData()
        

    }
    
    func onRemoveDownload(content: CommonContentProtocol, type: MoreMenuType) {
        DatabaseContext.shared.deleteSong(where: content.contentID ?? "")
        if let playUrl = content.playUrl{
            SDFileUtils.removeItemFromDirectory(urlName: playUrl)
            self.view.makeToast("File Removed from Download")
        }
    }
    //no need to implement this
    func onRemoveFromHistory(content: CommonContentProtocol) {
    }
    
    func gotoArtist(content: CommonContentProtocol) {
        let vc = goArtistVC(content: content)
        self.navigationController?.pushViewController(vc , animated: true )
    }
    
    func gotoAlbum(content: CommonContentProtocol) {
        let vc = goAlbumVC(isFromThreeDotMenu: true, content: content)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func addToPlaylist(content: CommonContentProtocol) {
        goAddPlaylistVC(content: content)
    }
    func shareMyPlaylist(content: CommonContentProtocol) {
        
    }
    
    func openSleepTimer() {
    
    }

}


//MARK: Download all and cancel handler
extension MusicArtistListVC {
    func downloadAllSongs(){
        guard try! Reachability().connection != .unavailable else {return}
        //post download info to server
        ///there is no system to  track artist download in system
        ///so its no need to add download history
        let model : CommonContentProtocol = discoverModel
        //ShadhinApi().downloadCompletePost(model: model)
        //send event to firebasee analytics
     //   AnalyticsEvents.downloadEvent(with: model.contentType, contentID: model.contentID, contentTitle: model.title)
        //add to artist datababse
        DatabaseContext.shared.addArtist(content: discoverModel)
        //add songs to download database, waiting for downfload
        artistSongs.forEach { data in
            var content : CommonContentProtocol = data
            //its "gojamil"
            //found diffrent artist id from song
            //forcely change artist id
            content.artistID = artistID
            do{
                if let _ =  try DatabaseContext.shared.isSongExist(contentId: data.contentID!){
                    //nonthing to do because song all ready downloaded
//                    song.isSingleDownload = false
//                    DatabaseContext.shared.save()
                    //Log.info("Song exist")
                }else{
                    DatabaseContext.shared.addDownload(content: content,isSingleDownload: false)
                }
            }catch{
                Log.error(error.localizedDescription)
            }
        }
        SDDownloadManager.shared.checkDatabase()
        //tableView.reloadData()
    }
    func cancellAllDownload(){
        let artistID = ((discoverModel.artistID != nil) ? discoverModel.artistID : discoverModel.contentID) ?? ""
        //delete artist from artist databae
        DatabaseContext.shared.deleteArtist(where: artistID)
        //delete if download remaing
        DatabaseContext.shared.downloadRemaingBatchDeleteArtist(where: artistID)
        //delete downloaded songs if artist songs downloaded
        DatabaseContext.shared.deleteSongsByArtist(where: artistID)
        //delete all download request
        for song in artistSongs{
            if SDDownloadManager.shared.isDownloadInProgress(forKey: song.playUrl){
                if let key = song.playUrl, let url = URL(string: key){
                    SDDownloadManager.shared.cancelDownload(forUniqueKey: url.lastPathComponent)
                }
            }
            //remove song from local directory
            if let playUrl = song.playUrl{
                SDFileUtils.removeItemFromDirectory(urlName: playUrl)
            }
        }
        //check songs loads from internet or local
        if try! Reachability().connection == .unavailable{
            //load from local
            //pop back
            navigationController?.popViewController(animated: true)
        }
        self.tableView.reloadData()
    }
    
}


extension MusicArtistListVC: ReadMoreLessViewDelegate{
    func didClickButton(_ readMoreLessView: ReadMoreLessView) {
        if readMoreLessView.state == .collapsed{
            self.state = .expanded
        }else{
            self.state = .collapsed
        }
        let index = IndexPath(row: 0, section: 0)
//        self.tableView.beginUpdates()
        self.tableView.reloadRows(at: [index], with: .automatic)
//        self.tableView.needsUpdateConstraints()
//        self.tableView.endUpdates()
    }
    
    func didChangeState(_ readMoreLessView: ReadMoreLessView) {
        //self.state.toggle()
//        let index = IndexPath(row: 0, section: 0)
//        self.tableView.reloadRows(at: [index], with: .automatic)
    }
}

