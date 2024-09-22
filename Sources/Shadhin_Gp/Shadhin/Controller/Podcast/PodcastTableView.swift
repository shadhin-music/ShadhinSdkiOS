//
//  PodcastTableView.swift
//  Shadhin
//
//  Created by Rezwan on 6/11/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//
import UIKit

extension PodcastVC{
    
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if podcastModel == nil{
            return 1
        }
        return 2
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1{
            return (userComments != nil ? (1 + userComments!.data.count) : 1)
        }
        if  podcastModel == nil || podcastModel?.data.episodeList.count == 0 {
            return 0
        }
        var count = podcastModel!.data.episodeList[selectedEpisode].trackList.count
        if willLoadAds{
            let adsCountDouble = Double(count) / 3.0
            let adsCountInt = Int(adsCountDouble.rounded(.up))
            //print("count += adsCountInt -> \(count) \(adsCountInt)")
            count += adsCountInt
        }
        return 2 + count + (shouldShowEpisodes ? 1 : 0)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1{
            return tableViewComments( tableView, indexPath)
        }
        
        
        let totalCount = shouldShowEpisodes ? self.tableView(tableView, numberOfRowsInSection: 0) : -1
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: PodcastHeaderOneViewCell.identifier, for: indexPath) as! PodcastHeaderOneViewCell
            cell.titleLabel.text = headerTitle
            cell.subTitleLabel.text = headerSubTitle
            var imageVarient = "300"
            if podcastType == "VD"{
                cell.mainImgWidth.constant = 320
                imageVarient = "1280"
                cell.mainImg.cornerRadius = 8
                cell.playOverlayBtn.isHidden = false
                cell.playOverlayBtn.setClickListener {
                    guard let track = self.podcastModel?.data.episodeList[self.selectedEpisode].trackList[0] else{
                        return
                    }
                    
                    if track.isPaid ?? false && !ShadhinCore.instance.isUserPro {
                        //self.goSubscriptionTypeVC()
                        NavigationHelper.shared.navigateToSubscription(from: self)
                        return
                    }
                    self.playMediaAtIndex(0)
                }
            }else{
                cell.playOverlayBtn.isHidden = true
                cell.mainImgWidth.constant = 180
                imageVarient = "300"
                cell.mainImg.cornerRadius = 16
            }
            
            if headerImg != nil {
                let imgUrl = headerImg!.replacingOccurrences(of: "<$size$>", with: imageVarient)
                cell.bgImg.kf.setImage(with: URL(string: imgUrl.safeUrl()))
                cell.mainImg.kf.indicatorType = .activity
                cell.mainImg.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_radio",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
            }
            
            cell.shareBtn.setClickListener {
                self.share()
            }
            
            cell.backBtn.setClickListener {
                self.dismiss()
            }
            
            cell.shareBtnC.setClickListener {
                self.share()
            }
            
            self.playBtn = cell.playBtn
            self.favBtn = cell.favBtn
            guard let track = self.podcastModel?.data.episodeList[self.selectedEpisode].trackList[0], let selectedTrack = self.selectedTrack else{
                fatalError()
            }
            cell.bind(content: selectedTrack)
            cell.playBtn.setClickListener {
                
                #if DEBUG
                //track.playUrl = "iSRkuLCT7So"
                //track.trackType = "LM"
                #endif
                
                if track.isPaid ?? false && !ShadhinCore.instance.isUserPro {
                    NavigationHelper.shared.navigateToSubscription(from: self)
                    return
                }
                
                if self.shouldPlay {
                    
                    if MusicPlayerV3.audioPlayer.state == .stopped || self.playBtn?.tag == 0{
                        self.playBtn?.tag = 1
                        self.playMediaAtIndex(0)
                    }else {
                        MusicPlayerV3.audioPlayer.resume()
                        cell.playBtn.setImage(UIImage(named: "ic_Pause1",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                    }
                    MusicPlayerV3.isAudioPlaying = false
                    self.shouldPlay = false
                }else {
                    MusicPlayerV3.audioPlayer.pause()
                    cell.playBtn.setImage(UIImage(named: "ic_Play",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                    MusicPlayerV3.isAudioPlaying = true
                    self.shouldPlay = true
                }
                
            }
            
            cell.favBtn.setClickListener {
                self.addDeleteFav()
            }
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: PodcastHeaderTwoViewCell.identifier, for: indexPath) as! PodcastHeaderTwoViewCell
//            headerAbout?.attributedStringFromHTML(completionBlock: { attrStr in
//                DispatchQueue.main.async { [weak cell] in
//                    if let attrStr = attrStr{
//                        cell?.aboutLabel.attributedText = attrStr
//                    }else{
//                        cell?.aboutLabel.text = self.headerAbout
//                        cell?.aboutLabel.textColor = .primaryLableColor()
//                    }
//                    self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
//                 }
//            })
//            headerAbout?.stringFromHTML(completionBlock: { str in
//                DispatchQueue.main.async {  [weak cell, weak self] in
//                    guard let strongSelf = self else {return}
//                    if let str = str{
//                        cell?.aboutLabel.setText(text: str, state: strongSelf.state)
//                    }else{
//                        cell?.aboutLabel.text = strongSelf.headerAbout ?? ""
//                    }
//                    strongSelf.tableView.reloadSections(IndexSet(integer: 0), with: .none)
//                }
//            })
            cell.aboutLabel.text = headerAboutStr
            cell.aboutLabel.delegate = self
            cell.aboutLabel.state = self.state
          //  shouldLoadAd(container: cell.adBannerView, container2: cell.adBannerMax)
            return cell
            
        case totalCount - 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: PodcastFooterViewCell.identifier, for: indexPath) as! PodcastFooterViewCell
            if cell.collectionView.dataSource == nil{
                cell.collectionView.dataSource = self
                cell.collectionView.delegate = self
            }
            cell.seeAllBtn.setClickListener {
                self.seeAllEpisodes()
            }
            cell.collectionView.reloadData()
            return cell
        default:
            
            var index = indexPath.row  - 2
//            
//            if isIndexAnAd(index: index){
//                let useAdProvider = Bundle.main.object(forInfoDictionaryKey: "UseAdProvider") as? String
//                if useAdProvider == "google"{
//                    let cell =  tableView.dequeueReusableCell(withIdentifier: NativeSmallAdTCell.identifier, for: indexPath) as! NativeSmallAdTCell
//                    if let nav = self.navigationController, let ad = NativeAdLoader.shared(nav).getNativeAd(){
//                        cell.loadAd(nativeAd: ad)
//                    }
//                    return cell
//                }else if useAdProvider == "applovin"{
//                    let cell =  tableView.dequeueReusableCell(withIdentifier: NativeAdMaxSmall.identifier, for: indexPath) as! NativeAdMaxSmall
//                    cell.tableview = self.tableView
//                    return cell
//                }
//            }
            
            index = getAdAdjustedRow(row: index)
            
            let cell = tableView.dequeueReusableCell(withIdentifier: PodcastItemViewCell.identifier, for: indexPath) as! PodcastItemViewCell
            
            if let track = podcastModel?.data.episodeList[selectedEpisode].trackList[index]{
                
                cell.trackTitle.text = track.name
                
                let dateFormatter = DateFormatter()
                var dateString = ""
                dateFormatter.dateFormat = "yyyy'-'MM'-'dd"
                if let date = dateFormatter.date(from: track.ceateDate){
                    let dateFormatterPrint = DateFormatter()
                    dateFormatterPrint.dateFormat = "MMM dd yy"
                    dateString = dateFormatterPrint.string(from: date)
                }
                
                var str = ""
                if let duration = track.duration, !duration.isEmpty{
                    str = dateString + " • " + duration
                }else{
                    str = dateString
                }
                
                if let streamCount = track.totalStream, streamCount > 0{
                    str = str + " • " + streamCount.roundedWithAbbreviations + " plays"
                }
                 cell.trackSubTitile.text = str
               
                var imageVarient = 300
                if podcastType == "VD"{
                    cell.shortStoryImageWidth.constant = 75
                    cell.shortStoryImage.cornerRadius = 4
                    imageVarient = 1280
                }else{
                    cell.shortStoryImageWidth.constant = 42
                    cell.shortStoryImage.cornerRadius = 11
                    imageVarient = 300
                }
                
                let imgUrl = ShadhinApi.getImageUrl(url: track.imageURL, size: imageVarient)
                cell.shortStoryImage.kf.indicatorType = .activity
                cell.shortStoryImage.kf.setImage(with: imgUrl,placeholder: UIImage(named: "default_radio",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
                

                //print(cell.menuButton.isHidden)
                if track.trackType == "L"  || track.trackType == "LM"{
                    cell.menuButton.isHidden = true
                    cell.proIc.isHidden = false
                    cell.proIc.image = UIImage(named: "ic_live",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
                }else{
                    cell.proIc.image = UIImage(named: "ic_get_pro",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
                    if ShadhinCore.instance.isUserPro{
                        cell.proIc.isHidden = true
                        cell.menuButton.isHidden = false
                    }else{
                        cell.proIc.isHidden = !(track.isPaid ?? false)
                        cell.menuButton.isHidden = track.isPaid ?? false
                    }
                    //cell.menuButton.isHidden = false
                    cell.checkPodcastIsDownloading(data: track)
                }

                cell.setClickListener {
                    if track.isPaid ?? false && !ShadhinCore.instance.isUserPro {
                        
                        //self.goSubscriptionTypeVC()
                        NavigationHelper.shared.navigateToSubscription(from: self)
                        return
                   }
                    
                    self.playMediaAtIndex(index)
                    self.playBtn?.setImage(UIImage(named: "ic_Pause1",in:Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                    self.playBtn?.tag = 1
                    MusicPlayerV3.isAudioPlaying = false
                    self.shouldPlay = false
                }
                
                cell.didThreeDotMenuTapped {
                    let menu = MoreMenuVC()
                    menu.data = track
                    menu.delegate = self
                    menu.openForm = .Podcast
                    menu.menuType = self.podcastType == "PD" ? .Podcast : .PodCastVideo
                    let height = self.podcastType == "PD" ? MenuLoader.getHeightFor(vc: .Podcast, type: .Podcast) : MenuLoader.getHeightFor(vc: .Podcast, type: .PodCastVideo)
                    var attribute = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 0)
                    attribute.entryBackground = .color(color: .clear)
                    attribute.border = .none
                    SwiftEntryKit.display(entry: menu, using: attribute)
                }
                
                if DatabaseContext.shared.isPodcastExist(where: track.contentID ?? ""){
                    cell.downloadMark.image  = AppImage.downloadIcon.uiImage
                }else{
                    cell.downloadMark.image = AppImage.nonDownload12.uiImage
                }
                
            }
            return cell
        }
        
    }
    
    func tableViewComments(_ tableView: UITableView,_ indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: CommentHeaderCell.identifier, for: indexPath) as! CommentHeaderCell
            cell.totalCommentsLabel.text = "\(userComments?.totalData ?? 0)"
            cell.commentRefreshBtn.addTarget(self, action: #selector(reloadComments), for: .touchUpInside)
            cell.addCommentView.setClickListener {
                self.addComment()
            }
            return cell
        default:
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.identifier, for: indexPath) as! CommentCell
            if let comment = userComments?.data[indexPath.row - 1]{
                cell.userImg.kf.indicatorType = .activity
                
                if let userPicUrlEncoded = comment.userPic.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed){
                    cell.userImg.kf.setImage(with: URL(string:userPicUrlEncoded ),placeholder: UIImage(named: "ic_user_1",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
                }
                if comment.adminUserType.isEmpty{
                    if comment.isSubscriber ?? false{
                        let imageAttachment = NSTextAttachment()
                        imageAttachment.image = UIImage(named: "ic_verified_user",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
                        let imageOffsetY: CGFloat = -1.0
                        imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
                        let attachmentString = NSAttributedString(attachment: imageAttachment)
                        let completeText = NSMutableAttributedString(string: "")
                        let textAfterIcon = NSAttributedString(string: "\(comment.userName) ")
                        completeText.append(textAfterIcon)
                        completeText.append(attachmentString)
                        cell.userName.attributedText = completeText
                    }else{
                        cell.userName.text = comment.userName
                    }
                }else{
                    let imageAttachment = NSTextAttachment()
                    imageAttachment.image = UIImage(named:"verified_2",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
                    let imageOffsetY: CGFloat = -1.0
                    imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
                    let attachmentString = NSAttributedString(attachment: imageAttachment)
                    let completeText = NSMutableAttributedString(string: "")
                    let textAfterIcon = NSAttributedString(string: "\(comment.userName) ")
                    completeText.append(textAfterIcon)
                    completeText.append(attachmentString)
                    cell.userName.attributedText = completeText
                }
                cell.comment.text = comment.message
                cell.favCount.text = "\(comment.totalCommentFavorite)"
                if comment.totalReply > 0{
                    cell.replyCountBtn.isHidden = false
                    cell.replyCountBtn.setTitle("\(comment.totalReply) replies", for: .normal)
                    cell.replyCountBtn.setClickListener {
                        self.viewReply(comment, indexPath)
                    }
                }else{
                    cell.replyCountBtn.isHidden = true
                }
                cell.replyBtn.setClickListener {
                    self.viewReply(comment, indexPath)
                }
                if comment.commentFavorite{
                    cell.favImg.image = UIImage(named: "ic_mymusic_favorite",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
                }else{
                    cell.favImg.image = UIImage(named: "ic_favorite_border",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
                }
                if comment.commentLike{
                    cell.likeBtn.setTitle("You liked", for: .normal)
                    cell.likeBtn.setTitleColor(UIColor.red.withAlphaComponent(0.7), for: .normal)
                }else{
                   cell.likeBtn.setTitle("Like", for: .normal)
                    if #available(iOS 13.0, *) {
                        cell.likeBtn.setTitleColor(.secondaryLabel, for: .normal)
                    } else {
                        cell.likeBtn.setTitleColor(.gray, for: .normal)
                    }
                }
                
                let dateFormatter = DateFormatter()
                //dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                //dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
                if let date =  dateFormatter.date(from: comment.createDate){
                    cell.timeAgo.text = timeAgoSince(date)
                }else{
                    cell.timeAgo.text = " "
                }
                
                cell.podcastVC = self
                cell.commentIndex = indexPath
                cell.initComment()
                
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1{
            switch indexPath.row {
            case 0 :
                return CommentHeaderCell.height
            default :
                return CommentCell.height
            }
        }
        
        let totalCount = shouldShowEpisodes ? self.tableView(tableView, numberOfRowsInSection: 0) : -1
        
        switch indexPath.row {
        case 0:
            return PodcastHeaderOneViewCell.height
        case 1:
            return UITableView.automaticDimension
        case totalCount - 1:
            if podcastModel?.data.episodeList.count ?? 0 > 1{
                return PodcastFooterViewCell.height
            }
            return .leastNonzeroMagnitude
        default:
            let index = indexPath.row  - 2
//            if isIndexAnAd(index: index){
//                let useAdProvider = Bundle.main.object(forInfoDictionaryKey: "UseAdProvider") as? String
//                if useAdProvider == "google"{
//                    return NativeSmallAdTCell.size
//                }else if useAdProvider == "applovin"{
//                    return NativeAdMaxSmall.size
//                }else{
//                    return .leastNormalMagnitude
//                }
//            }
            return PodcastItemViewCell.height
        }
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.cellHeightsDictionary[indexPath] = cell.frame.size.height
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height =  self.cellHeightsDictionary[indexPath] {
            return height
        }
        return UITableView.automaticDimension
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        loadMoreComments?.start {
            self.getComments({self.loadMoreComments?.stop()})
        }
    }
    
}

extension PodcastVC: ReadMoreLessViewDelegate{
    func didClickButton(_ readMoreLessView: ReadMoreLessView) {
        if readMoreLessView.state == .collapsed{
            self.state = .expanded
        }else{
            self.state = .collapsed
        }
        if(tableView.numberOfSections > 0 && tableView.numberOfRows(inSection: 0) > 1){
            let index = IndexPath(row: 1, section: 0)
            self.tableView.reloadRows(at: [index], with: .automatic)
        }
    }
    
    func didChangeState(_ readMoreLessView: ReadMoreLessView) {
       
    }
}
