//
//  HomeSeeAllVC.swift
//  Shadhin
//
//  Created by MacBook Pro on 31/12/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit

class HomeSeeAllVC: UIViewController,NIBVCProtocol {
    var coordinator : HomeCoordinator?
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var patch : HomePatch?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(SquareV3Cell.nib, forCellWithReuseIdentifier: SquareV3Cell.identifier)
        collectionView.contentInset = .init(top: 8, left: 16, bottom: 8, right: 16)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        titleLabel.text = patch?.title

    }
    @IBAction func onBackPressed(_ sender: Any) {
        self.coordinator?.pop()
    }
    

}
extension HomeSeeAllVC : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return patch?.contents.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SquareV3Cell.identifier, for: indexPath) as? SquareV3Cell,let obj = patch?.contents[indexPath.row] else{
            fatalError()
        }
        //cell.bindForFavouroteArtist(with: <#T##ContentDataProtocol#>)
        cell.subtitleLabel.isHidden = true
        cell.bind(with: obj)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let obj = patch?.contents[indexPath.row] else {fatalError()}
        coordinator?.routeToContent(content: obj)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w : CGFloat = floor((UIScreen.main.bounds.width - 50) / 3)
        let r = SquareV3Cell.sizeForLatestRelease.height / SquareV3Cell.sizeForLatestRelease.width
        let h : CGFloat = floor(w * r)
        return .init(width: w, height: h)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}
