//
//  TopPopularItemCell.swift
//  Shadhin
//
//  Created by Joy on 24/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit


class CircularWithFavBtnSub: UICollectionViewCell {
    
    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    static var size : CGSize{
        return .init(width: 135, height: 212)
    }
    
    @IBOutlet weak var imageIV: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var favCountLabel: UILabel!
    
    var content : CommonContentProtocol?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        imageIV.cornerRadius = imageIV.height / 2
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.textColor  = .textColor
        favCountLabel.textColor = .textColorSecoundery
        followButton.setTitle("Follow", for: .normal)
        followButton.setTitle("Following", for: .selected)
        followButton.setTitleColor(.tintColor, for: .normal)
        followButton.setTitleColor(.textColorSecoundery, for: .selected)
        followButton.layer.cornerRadius = 12
        followButton.layer.borderWidth = 1
        
        if self.traitCollection.userInterfaceStyle == .dark{
            self.followButton.layer.borderColor = UIColor.white.withAlphaComponent(0.3)
                .cgColor
        }else{
            self.followButton.layer.borderColor = UIColor.black.withAlphaComponent(0.1)
                .cgColor
        }
        
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self], handler: { (self: Self, previousTraitCollection: UITraitCollection) in
                if self.traitCollection.userInterfaceStyle == .light {
                    // Code to execute in light mode
                    self.followButton.layer.borderColor = UIColor.black.withAlphaComponent(0.1)
                        .cgColor
                }else {
                    // Code to execute in dark mode
                    print("App switched to dark mode")
                    self.followButton.layer.borderColor = UIColor.white.withAlphaComponent(0.3)
                        .cgColor
                }
            })
        } else {
            // Fallback on earlier versions
        }
    }

    func bind(obj : CommonContentProtocol){
        self.content = obj
        self.titleLabel.text = obj.title
        self.favCountLabel.text = obj.followers
        self.imageIV.kf.setImage(with: URL(string: obj.image?.image300 ?? ""),placeholder: AppImage.artistPlaceholder.uiImage)
        self.followButton.isSelected = FavoriteCacheDatabase.intance.isFav(content: obj)
        
        
    }
    @IBAction func onFollowPressed(_ sender: Any) {
        guard let content = content else {return}
        if  FavoriteCacheDatabase.intance.isFav(content: content){
            ShadhinCore.instance.api.addOrRemoveFromFavorite(content: content, action: .remove) { error in
                if error == nil{
                    FavoriteCacheDatabase.intance.deleteContent(content: content)
                    self.followButton.isSelected = false
                    
                }
            }
        }else{
            ShadhinCore.instance.api.addOrRemoveFromFavorite(content: content, action: .add) { error in
                if error == nil{
                    FavoriteCacheDatabase.intance.addContent(content: content)
                    self.followButton.isSelected = true
                    
                }
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection?.userInterfaceStyle == .light {
            // Code to execute in light mode
            self.followButton.layer.borderColor = UIColor.white.withAlphaComponent(0.3)
                .cgColor
        }else {
            // Code to execute in dark mode
            print("App switched to dark mode")
            self.followButton.layer.borderColor = UIColor.black.withAlphaComponent(0.1)
                .cgColor
        }
    }
}

