//
//  Top3RankCell.swift
//  Shadhin_BL
//
//  Created by Joy on 11/1/23.
//

import UIKit

class Top3RankCell: UICollectionViewCell {

    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.main)
    }
    static var height : CGFloat{
        return  200 + 16
    }
    
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    
    
    @IBOutlet weak var icon1IV: UIImageView!
    @IBOutlet weak var icon3IV: UIImageView!
    @IBOutlet weak var icon2IV: UIImageView!
    
    @IBOutlet weak var hour1Label: UILabel!
    @IBOutlet weak var hour2Label: UILabel!
    @IBOutlet weak var hour3Label: UILabel!
    
    @IBOutlet weak var number1Label: UILabel!
    @IBOutlet weak var number2Label: UILabel!
    @IBOutlet weak var number3Label: UILabel!
    
    @IBOutlet weak var name1Label: UILabel!
    @IBOutlet weak var name2Label: UILabel!
    @IBOutlet weak var name3Label: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        view1.layer.cornerRadius = 12
        view1.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.08).cgColor
        view1.layer.shadowOpacity = 1
        view1.layer.shadowRadius = 2
        view1.layer.shadowOffset = CGSize(width: 1, height: 2)
        
        view2.layer.cornerRadius = 10
        view2.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.08).cgColor
        view2.layer.shadowOpacity = 1
        view2.layer.shadowRadius = 2
        view2.layer.shadowOffset = CGSize(width: 1, height: 2)
        
        
        view3.layer.cornerRadius = 10
        view3.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.08).cgColor
        view3.layer.shadowOpacity = 1
        view3.layer.shadowRadius = 2
        view3.layer.shadowOffset = CGSize(width: 1, height: 2)
        
        number1Label.adjustsFontSizeToFitWidth = true
        number2Label.adjustsFontSizeToFitWidth = true
        number3Label.adjustsFontSizeToFitWidth = true
        
        name1Label.adjustsFontSizeToFitWidth = true
        name2Label.adjustsFontSizeToFitWidth = true
        name3Label.adjustsFontSizeToFitWidth = true
        
        icon1IV.layer.borderWidth = 2
        icon2IV.layer.borderWidth = 2
        icon3IV.layer.borderWidth = 2
        
        icon1IV.layer.borderColor = UIColor(red: 0.961, green: 0.969, blue: 0.988, alpha: 1).cgColor
        icon2IV.layer.borderColor = UIColor(red: 0.961, green: 0.969, blue: 0.988, alpha: 1).cgColor
        icon3IV.layer.borderColor = UIColor(red: 0.961, green: 0.969, blue: 0.988, alpha: 1).cgColor
        
    }
    func bind(with ranks : [RankBkashResponse]){
        guard ranks.count == 3 else {return}
        let second = ranks[1]
        let third = ranks[2]
        
        if  let first = ranks.first{
            if let name = first.userFullName{
                name1Label.text = name
                number1Label.text = first.msisdn
                number1Label.isHidden = false
            }else {
                name1Label.text = first.msisdn
                number1Label.isHidden = true
            }
            
            hour1Label.text = getStrimingTime(sec: first.timeCountSecond)
            
            if let img = first.imageURL{
                if img.isValidURL, let url = URL(string: img){
                    icon1IV.kf.setImage(with: url,placeholder: AppImage.userAvatar.uiImage)
                }else{
                    let ii = "\(ShadhinApiURL.IMAGE_BASE_URL)/\(img)"
                    icon1IV.kf.setImage(with: URL(string: ii),placeholder: AppImage.userAvatar.uiImage)
                }
                
            }
        }
        
        if let name = second.userFullName{
            name2Label.text = name
            number2Label.text = second.msisdn
            number2Label.isHidden = false
        }else {
            name2Label.text = second.msisdn
            number2Label.isHidden = true
        }
        hour2Label.text = getStrimingTime(sec: second.timeCountSecond)
        
        if let img = second.imageURL{
            if img.isValidURL, let url = URL(string: img){
                icon2IV.kf.setImage(with: url,placeholder: AppImage.userAvatar.uiImage)
            }else{
                let ii = "\(ShadhinApiURL.IMAGE_BASE_URL)/\(img)"
                icon2IV.kf.setImage(with: URL(string: ii),placeholder: AppImage.userAvatar.uiImage)
            }
            
        }
        
        if let name = third.userFullName{
            name3Label.text = name
            number3Label.text = third.msisdn
            number3Label.isHidden = false
        }else {
            name3Label.text = second.msisdn
            number3Label.isHidden = true
        }
        hour3Label.text = getStrimingTime(sec: third.timeCountSecond)
        if let img = third.imageURL{
            if img.isValidURL, let url = URL(string: img){
                icon3IV.kf.setImage(with: url,placeholder: AppImage.userAvatar.uiImage)
            }else{
                let ii = "\(ShadhinApiURL.IMAGE_BASE_URL)/\(img)"
                icon3IV.kf.setImage(with: URL(string: ii),placeholder: AppImage.userAvatar.uiImage)
            }
            
        }
        
    }
}
func getStrimingTime(sec : Int)-> String{
    
    if sec >= (60 * 60){
        return String(format: "%.1f hrs", Float(Float(sec) / 3600.0))
    }else if sec >= 60 {
        return String(format: "%.1f min",Float(Float(sec) / 60.0))
    }else{
        return "\(sec) sec"
    }
}
func getUserStrimingTime(sec : Int)-> String{
    
    if sec >= (60 * 60){
        let h = sec / (60 * 60)
        let min = (sec % (60 * 60)) / 60
        
        return "\(h)hrs \(min)min"
    }else if sec >= 60 {
        return String(format: "%.1f min",Float(Float(sec) / 60.0))
    }else{
        return "\(sec) sec"
    }
}
