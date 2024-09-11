//
//  LatestAlbumCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/10/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

class PodcastCell: UICollectionViewCell {
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var size: CGSize {
        return CGSize(width: 142, height: 256) //190
    }

    @IBOutlet weak var albumImgView: UIImageView!
    @IBOutlet weak var albumTitleLbl: UILabel!
    @IBOutlet weak var albumArtistLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        albumTitleLbl.textColor = .customLabelColor(color: #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1))
    }
    
    func configureCell(model: CommonContentProtocol) {
        let imgUrl = model.image?.replacingOccurrences(of: "<$size$>", with: "450") ?? ""
        albumImgView.kf.indicatorType = .activity
        if model.contentType == "B" || model.contentType == "R" {
            albumImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_album"))
        }else {
            albumImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_song"))
        }
        albumTitleLbl.text = model.title ?? ""
        albumArtistLbl.text = "\(model.playCount ?? 0) plays"
    }
    
    
}
