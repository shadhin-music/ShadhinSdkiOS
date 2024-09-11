//
//  DiscoverMusicDetailsCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/20/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit


class DiscoverMusicDetailsCell: UICollectionViewCell {
    
    @IBOutlet weak var albumImgView: UIImageView!
    @IBOutlet weak var albumTitleLbl: UILabel!
    @IBOutlet weak var albumArtistLbl: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        albumTitleLbl.textColor = .customLabelColor(color: #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1))
    }
    
    func configureCell(model: CommonContentProtocol) {
        let imgUrl = model.image?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
        albumImgView.kf.indicatorType = .activity
        if model.contentType == "B" || model.contentType == "R" {
            albumImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_album"))
        }else {
            albumImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_song"))
        }
        albumTitleLbl.text = model.title ?? ""
        albumArtistLbl.text = model.artist ?? ""
    }
    
    func configureCellForMyMusic(model: CommonContentProtocol) {
        let imgUrl = model.image?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
        albumImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_album"))
        albumTitleLbl.text = model.title ?? ""
        albumArtistLbl.text = model.artist ?? ""
    }
    
    func configureCellForPlaylist(model: PlaylistsObj.PlaylistDetails) {
        albumTitleLbl.text = model.name
        albumArtistLbl.text = "5 Songs"
    }
    
    var isEditing: Bool = false {
        didSet {
            UIView.transition(with: deleteBtn, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.deleteBtn.isHidden = !self.isEditing
            })
        }
    }
    
    func shake() {
        let shakeAnimation = CABasicAnimation(keyPath: "transform.rotation")
        shakeAnimation.duration = 0.10
        shakeAnimation.repeatCount = 2
        shakeAnimation.autoreverses = true
        let startAngle: Float = (-2) * 3.14159/180
        let stopAngle = -startAngle
        shakeAnimation.fromValue = NSNumber(value: startAngle as Float)
        shakeAnimation.toValue = NSNumber(value: 3 * stopAngle as Float)
        shakeAnimation.autoreverses = true
        shakeAnimation.duration = 0.20
        shakeAnimation.repeatCount = 10000
        shakeAnimation.timeOffset = 290 * drand48()

        let layer: CALayer = self.layer
        layer.add(shakeAnimation, forKey:"shaking")
    }

    func stopShaking() {
        let layer: CALayer = self.layer
        layer.removeAnimation(forKey: "shaking")
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        //delegate?.didAlbumItemsDeleteTapped(cell: self)
    }
}
