//
//  ShuffleWithDownloadView.swift
//  Shadhin
//
//  Created by Joy on 25/9/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit

class ShuffleAndDownloadView: UIView {
    let xibName = "ShuffleAndDownloadView"
    var contentView: UIView!
    var shadowLayer: CAShapeLayer!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var downloadProgress: SpinnerProgressView!
    var rootContent: CommonContentProtocol? = nil
    var contentID: String? = nil
    var contentType: String? = nil
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    override init(frame: CGRect) {
           super.init(frame: frame)
           commonInit()
       }

       required init?(coder aDecoder: NSCoder) {
           super.init(coder: aDecoder)
           commonInit()
       }
       
       func commonInit() {
           //Bundle.module.loadNibNamed(xibName, owner: self, options: [:])
           loadViewFromNib()
       }
    
    func loadViewFromNib() {
          //let bundle = Bundle(for: ShuffleAndDownloadView.self)
        contentView = ShuffleAndDownloadView.nib.instantiate(withOwner: self).first as? UIView
          contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
          contentView.frame = bounds
          addSubview(contentView)
        NotificationCenter.default.addObserver(self, selector: #selector(updateShuffleBtn), name: .init(rawValue: "ShuffleListNotify"), object: nil)
    }
    
    @objc func updateShuffleBtn(){
        guard let _contentID = contentID,
              let _contentType = contentType else {return}
        if ShadhinCore.instance.defaults.checkShuffle(contentId: _contentID,contentType: _contentType) {
            shuffleButton.setImage(UIImage(named: "shufflePlayOn",in:Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
        }  else {
            shuffleButton.setImage(UIImage(named: "shuffle",in: Bundle.ShadhinMusicSdk,compatibleWith:nil), for: .normal)
        }
    }
    
}
