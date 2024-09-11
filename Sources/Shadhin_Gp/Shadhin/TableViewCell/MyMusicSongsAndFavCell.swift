//
//  MyMusicRecentlyPlayedCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/24/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

class MyMusicSongsAndFavCell: UITableViewCell {
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    //       static var size: CGFloat {
    //           return 73
    //       }
    
    @IBOutlet weak var songsImgView: UIImageView!
    @IBOutlet weak var songTitleLbl: UILabel!
    @IBOutlet weak var songArtistLbl: UILabel!
    
    @IBOutlet weak var songsDurationLbl: UILabel!
    
    @IBOutlet weak var threeDotMenu: UIButton!
    @IBOutlet weak var threeDotBtn: UIButton!
    @IBOutlet weak var circularProgress: CircularProgress!
    @IBOutlet weak var downloadMarkImageView: UIImageView!
    
    private var threeDotMenuClick: (()->())?
    
    func configureCell(model: CommonContentProtocol,isFav: Bool) {
        songTitleLbl.text = model.title ?? ""
        if let sub = model.artist, sub.count > 0{
            songArtistLbl.text = sub
            downloadMarkImageView.isHidden = false
        }else if ((model.contentType?.hasPrefix("PD")) != nil){
            songArtistLbl.text =  "Podcast"
            downloadMarkImageView.isHidden = false
        }else{
            songArtistLbl.text = ""
            downloadMarkImageView.isHidden = true
        }
        
        songsDurationLbl.text = ""
        let time = TimeInterval(model.duration ?? "") ?? 0
        if time == 0{
            if let str = model.duration, str.count > 0{
                songsDurationLbl.text = str
            }else{
                songsDurationLbl.text = ""
            }
        }else{
            songsDurationLbl.text =  formatSecondsToString(time)
        }
        
        let imgUrl = model.image?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
        songsImgView.kf.indicatorType = .activity
        songsImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_song"))
        
        circularProgress.font = .systemFont(ofSize: 8)
        
        if DatabaseContext.shared.isSongExist(contentId: model.contentID!) || DatabaseContext.shared.isPodcastExist(where: model.contentID!){
            if #available(iOS 13, *){
                downloadMarkImageView.image = AppImage.checkCircelFill.uiImage
            }else{
                downloadMarkImageView.image = AppImage.downloaded12.uiImage
            }
        }else{
            if #available(iOS 13, *){
                downloadMarkImageView.image = AppImage.notDownload.uiImage
            }else{
                downloadMarkImageView.image = AppImage.nonDownload12.uiImage
            }
        }
        checkSongsIsDownloading(data: model)
    }
    
    
    func configureCell(model: CommonContentProtocol,isFav: Bool, hideMenu : Bool) {
        songTitleLbl.text = model.title ?? ""
        songArtistLbl.text = model.artist ?? ""
        songsDurationLbl.text = ""
        let time = TimeInterval(model.duration ?? "") ?? 0
        if time == 0{
            if let str = model.duration, str.count > 0{
                songsDurationLbl.text = str
            }else{
                songsDurationLbl.text = ""
            }
        }else{
            songsDurationLbl.text =  formatSecondsToString(time)
        }
        
        let imgUrl = model.image?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
        songsImgView.kf.indicatorType = .activity
        songsImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_song"))
        
        if hideMenu{
            self.threeDotMenu.isHidden = true

        }
        checkSongsIsDownloading(data: model)
        if DatabaseContext.shared.isSongExist(contentId: model.contentID!){
            if #available(iOS 13, *){
                downloadMarkImageView.image = AppImage.checkCircelFill.uiImage
            }else{
                downloadMarkImageView.image = AppImage.downloaded12.uiImage
            }
        }else{
            if #available(iOS 13, *){
                downloadMarkImageView.image = AppImage.notDownload.uiImage
            }else{
                downloadMarkImageView.image = AppImage.nonDownload12.uiImage
            }
        }
      
    }
    
    private func checkSongsIsDownloading(data: CommonContentProtocol) {
        
        let isDownloading = SDDownloadManager.shared.isDownloadInProgress(forKey: data.playUrl)
        self.threeDotBtn.isHidden = isDownloading
        self.circularProgress.isHidden = !isDownloading
        
        if isDownloading {
            
            guard let obj = SDDownloadManager.shared.currentDownload(forKey: data.playUrl) else {
                return
            }
            //work it when download all song
            obj.progressBlock = { progress in
                self.circularProgress.setProgress(progress: progress, animated: true)
                if progress == 1.0{
                    self.threeDotBtn.isHidden = false
                    self.circularProgress.isHidden = true
                    self.makeToast("File successfully downloaded.")
                    if let type = data.contentType, type.uppercased().hasPrefix("PD"){
                        DatabaseContext.shared.addPodcast(content: data)
                    }else{
                        DatabaseContext.shared.addSong(content: data,isSingleDownload: obj.isSingle ?? true)
                    }
                    if #available(iOS 13, *){
                        self.downloadMarkImageView.image = AppImage.checkCircelFill.uiImage
                    }else{
                        self.downloadMarkImageView.image = AppImage.downloaded12.uiImage
                    }
                }
            }

        }
    }
    
    private func hideCellItem() {
        self.songTitleLbl.isHidden = true
        self.songsImgView.isHidden = true
        self.songArtistLbl.isHidden = true
        self.songsDurationLbl.isHidden = true
        self.threeDotBtn.isHidden = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        songTitleLbl.textColor = .customLabelColor(color: #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1))
        songsDurationLbl.textColor = .customLabelColor(color: #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1))
        circularProgress.isHidden = true
        circularProgress.font = .systemFont(ofSize: 8)
        songTitleLbl.adjustsFontSizeToFitWidth =  true
        songArtistLbl.adjustsFontSizeToFitWidth = true
    }
    
    @IBAction func threeDotMenuAction(_ sender: Any) {
        threeDotMenuClick?()
    }
    
    func didThreeDotMenuTapped(completion: @escaping (()->())) {
        threeDotMenuClick = completion
    }
}
