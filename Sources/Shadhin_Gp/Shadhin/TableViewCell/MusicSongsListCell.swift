//
//  MusicSongsListCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/13/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

class MusicSongsListCell: UITableViewCell {
    
    @IBOutlet weak var songsImgView: UIImageView!
    @IBOutlet weak var songTitleLbl: UILabel!
    @IBOutlet weak var songArtistLbl: UILabel!
    
    @IBOutlet weak var songsDurationLbl: UILabel!
    @IBOutlet weak var threeDotBtn: UIButton!
    @IBOutlet weak var circularProgress: CircularProgress!
    @IBOutlet weak var rbtBtn: UIButton!
    @IBOutlet weak var downloadMarkImageView: UIImageView!
    
    private var threeDotMenuClick: (()->())?
    
    func configureCell(model: CommonContentProtocol,contentType: String) {
        
        let imgUrl = model.image?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
        songsImgView.kf.indicatorType = .activity
        songsImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_song"))
        songTitleLbl.text = model.title ?? ""
        if model.artist!.isEmpty {
            songArtistLbl.isHidden = true
        } else {
            songArtistLbl.isHidden = false
            songArtistLbl.text = model.artist ?? ""
        }
        songsDurationLbl.text = formatSecondsToString(Double(model.duration ?? "") ?? 123)
        
        //        if contentType == "B" || contentType == "R" {
        //            songArtistLbl.isHidden = true
        //        }else {
        //            songArtistLbl.isHidden = false
        //            songArtistLbl.text = model.artist ?? ""
        //        }
        
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
    
    func configureTrackCell(model: CommonContentProtocol) {
        songArtistLbl.isHidden = true
        let imgUrl = model.image?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
        songsImgView.kf.indicatorType = .activity
        songsImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_song"))
        songTitleLbl.text = model.title ?? ""
        if model.artist!.isEmpty {
            songArtistLbl.isHidden = true
        } else {
            songArtistLbl.isHidden = false
            songArtistLbl.text = model.artist ?? ""
        }
        songsDurationLbl.text = formatSecondsToString(Double(model.duration ?? "") ?? 0)
        
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
    
    func checkSongsIsDownloading(data: CommonContentProtocol) {
        
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
                    self.circularProgress.setProgress(progress: 0.0)
                    //save to database
                    DatabaseContext.shared.addSong(content: data,isSingleDownload: obj.isSingle ?? true)
                    //get rootview controller
                   self.makeToast("File successfully downloaded.")
                    //check download mark
                    if #available(iOS 13, *){
                        self.downloadMarkImageView.image = AppImage.checkCircelFill.uiImage
                    }else{
                        self.downloadMarkImageView.image = AppImage.downloaded12.uiImage
                    }
                }
            }

//            SDDownloadManager.shared.alterBlocksForOngoingDownload(withUniqueKey:           data.playUrl, setProgress: { (progress) in
//                self.circularProgress.setProgress(progress: progress, animated: true)
//            }, setCompletion: { (err, url) in
//                //nothing do
//            })
            
        }
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
