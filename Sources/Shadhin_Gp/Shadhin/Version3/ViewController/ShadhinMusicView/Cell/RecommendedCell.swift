//
//  RecommendedCell.swift
//  Shadhin_Gp
//
//  Created by Maruf on 7/8/24.
//

import UIKit

class RecommendedCell: UICollectionViewCell {

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
