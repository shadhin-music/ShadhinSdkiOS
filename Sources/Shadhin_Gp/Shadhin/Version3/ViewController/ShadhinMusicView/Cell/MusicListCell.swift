//
//  MusicListCell.swift
//  Shadhin_Gp
//
//  Created by Maruf on 1/8/24.
//

import UIKit

class MusicListCell:FSPagerViewCell {
    
    @IBOutlet weak var catagoryImgView: UIImageView!
    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
