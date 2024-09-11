//
//  RankCell.swift
//  Shadhin_BL
//
//  Created by Joy on 11/1/23.
//

import UIKit

class RankCell: UICollectionViewCell {

    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.main)
    }
    static var HEIGHT : CGFloat{
        return 64 //+ 8
    }
    static var TOP_HEIGHT : CGFloat{
        return 64 //+ 4 + 16
    }
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var noLabel: UILabel!
    @IBOutlet weak var userImageIV: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var mobileNoLabel: UILabel!
    
    @IBOutlet weak var listenHourLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        shadowView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05).cgColor
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowRadius = 6
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 2.77)
        shadowView.layer.cornerRadius = 8
        shadowView.layer.masksToBounds = false
        
        containerView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05).cgColor
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = false
        
    }
    
    func bind(with rank : RankBkashResponse){
        self.noLabel.text = rank.userRank.toString
        if let name = rank.userFullName{
            self.userNameLabel.text = name
            self.mobileNoLabel.text = rank.msisdn
            self.mobileNoLabel.isHidden = false
        }else{
            self.userNameLabel.text = rank.msisdn
            self.mobileNoLabel.isHidden = true
            
        }
        if let img = rank.imageURL{
            if img.isValidURL, let url = URL(string: img){
                userImageIV.kf.setImage(with: url,placeholder: AppImage.userAvatar.uiImage)
            }else{
                let ii = "\(ShadhinApiURL.IMAGE_BASE_URL)/\(img)"
                userImageIV.kf.setImage(with: URL(string: ii),placeholder: AppImage.userAvatar.uiImage)
            }
            
        }
        self.listenHourLabel.text = getStrimingTime(sec: rank.timeCountSecond)
    }

}
