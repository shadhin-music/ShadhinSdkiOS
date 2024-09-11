//
//  BhootHomeCell.swift
//  Shadhin
//
//  Created by Joy on 20/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class PatchDescTopWithRecPortDescBelow: UICollectionViewCell {

    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var height : CGFloat{
        return 326
    }
    
    @IBOutlet weak var heightConstant: NSLayoutConstraint!
    @IBOutlet weak var collectionVieew: UICollectionView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageIV: UIImageView!
    
    private var dataSource : [CommonContentProtocol] = []
    var onItemClick : (CommonContentProtocol)-> Void = {_ in}
    var onSeeAll : ()-> Void = {}
    override func prepareForReuse() {
        super.prepareForReuse()
        imageIV.isHidden = false
        subtitleLabel.isHidden = false
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageIV.cornerRadius = 24
        titleLabel.textColor = .textColor
        subtitleLabel.textColor = .textColorSecoundery
        collectionVieew.register(PatchDescTopWithRecPortDescBelowSub.nib, forCellWithReuseIdentifier: PatchDescTopWithRecPortDescBelowSub.identifier)
        collectionVieew.contentInset = .init(top: 8, left: 0, bottom: 8, right: 0)
        collectionVieew.dataSource = self
        collectionVieew.delegate = self 
    }
    
    
    @IBAction func seeAllClicked(_ sender: Any) {
        onSeeAll()
    }
    
    
    func bind(with data : [CommonContentProtocol]){
        self.dataSource = data
        collectionVieew.reloadData()
    }
    func bind(with patch : HomePatch){
        titleLabel.text = patch.title
        if let subtitle = patch.description{
            subtitleLabel.text = subtitle
            heightConstant.constant = 64
        }else{
            imageIV.isHidden = true
            subtitleLabel.isHidden = true
            heightConstant.constant = 30
        }
        self.dataSource = patch.contents
        collectionVieew.reloadData()
        imageIV.kf.setImage(with: URL(string: patch.image ?? ""))
    }
}
extension PatchDescTopWithRecPortDescBelow : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PatchDescTopWithRecPortDescBelowSub.identifier, for: indexPath) as? PatchDescTopWithRecPortDescBelowSub else{
            fatalError()
        }
        cell.bind(with: dataSource[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onItemClick(dataSource[indexPath.row])
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return PatchDescTopWithRecPortDescBelowSub.sizeForBhoot
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

