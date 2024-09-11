//
//  ArtistSongsListCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/16/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit
import SwiftUI

class ArtistSongsListCell: UITableViewCell {

    @IBOutlet weak var songsImgView: UIImageView!
    @IBOutlet weak var songTitleLbl: UILabel!
    @IBOutlet weak var songArtistLbl: UILabel!
    @IBOutlet weak var songsDurationLbl: UILabel!
    @IBOutlet weak var threeDotBtn: UIButton!
    @IBOutlet weak var circularProgress: CircularProgress!
    @IBOutlet weak var rbtBtn: UIButton!
    @IBOutlet weak var downloadMarkImageView: UIImageView!
    
    private var threeDotMenuClick: (()->())?
    
    func configureCell(model: CommonContent_V2,_ showCount : Bool = false) {
        songTitleLbl.text = model.title ?? ""
        var countStr = showCount ? ""  : model.artist ?? ""
        if showCount{
            if let count = model.playCount {
                countStr = countStr + count.roundedWithAbbreviations + " Plays"
            }
        }
        songArtistLbl.text = countStr
        songsDurationLbl.text = formatSecondsToString(Double(model.duration ?? "") ?? 123)
        let imgUrl = ShadhinApi.getImageUrl(url: model.image ?? "", size: 300)
        songsImgView.kf.indicatorType = .activity
        songsImgView.kf.setImage(with: imgUrl,placeholder: UIImage(named: "default_song"))
        checkSongsIsDownloading(data: model)
        
        //check file exist local folder or not
        if DatabaseContext.shared.isSongExist(contentId: model.contentID ?? ""){
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
            //if download is on going then its needs to exicute
            guard let obj = SDDownloadManager.shared.currentDownload(forKey: data.playUrl) else {
                return
            }
            //for all download songs
            obj.progressBlock = { progress in
                Log.error("Progress : \(progress)")
                self.circularProgress.setProgress(progress: progress, animated: true)
                if progress == 1.0{
                    self.threeDotBtn.isHidden = false
                    self.circularProgress.isHidden = true
                    self.circularProgress.setProgress(progress: 0.0)
                    DatabaseContext.shared.addSong(content: data,isSingleDownload: obj.isSingle ?? true)
                    if #available(iOS 13, *){
                        self.downloadMarkImageView.image = AppImage.checkCircelFill.uiImage
                    }else{
                        self.downloadMarkImageView.image = AppImage.downloaded12.uiImage
                    }
                    self.makeToast("File successfully downloaded.")
                }
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        songTitleLbl.textColor = .customLabelColor(color: #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1))
        songsDurationLbl.textColor = .customLabelColor(color: #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1))
        circularProgress.isHidden = true
        circularProgress.font = .systemFont(ofSize: 8)
    }
    
    @IBAction func threeDotMenuAction(_ sender: Any) {
        threeDotMenuClick?()
    }
    
    func didThreeDotMenuTapped(completion: @escaping (()->())) {
        threeDotMenuClick = completion
    }

}
