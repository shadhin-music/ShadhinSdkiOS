//
//  LeaderBoardAdapter.swift
//  Shadhin_BL
//
//  Created by Joy on 11/1/23.
//

import UIKit

protocol LeaderboardAdapterProtocol  : NSObjectProtocol{
    func onCampaignChange(_ campaign : CampaignSegment)
    func onMyRankPressed()
    func onPrizePressed(url : String)
    func onTermsAndConditionPressed(url : String)
}

class LeaderBoardAdapter: NSObject {
    
    
    private weak var delegate : LeaderboardAdapterProtocol?
    private var payment : PaymentMethod?
    
    private var userRank : RankBkashResponse?
    private var top3Rank : [RankBkashResponse]?
    private var allUserRank : [RankBkashResponse]?
    private var prize : PrizeResponse?
    private var campaignID : Int = 1
    
    init(delegate: LeaderboardAdapterProtocol? = nil, payment: PaymentMethod?) {
        self.delegate = delegate
        self.payment = payment
    }
    func setPaymentMethod( method : PaymentMethod?){
        self.payment = method
    }
    func setUserRank(_ rank : RankBkashResponse){
        self.userRank = rank
    }
    func setAllUserRank(_ ranks : [RankBkashResponse]){
        guard ranks.count > 3 else{
            top3Rank = nil
            allUserRank = nil
            return
        }
        top3Rank = Array(ranks.prefix(3))
        allUserRank = Array(ranks.suffix(from: 3))
    }
    
    func setPrize(prize : PrizeResponseArr){
        guard let payment = payment else {return}
        
        if let p =  prize.first(where: {$0.paymentPartner.uppercased() == payment.name.uppercased()}){
            self.prize = p
            return
        }
    }
    
}

extension LeaderBoardAdapter : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section{
        case 0:
            return payment == nil ? 0 : 1
        case 1:
            return top3Rank == nil ? 0 : 1
        case 2:
            return userRank ==  nil ? 0 : 1
        case 3:
            return allUserRank?.count ?? 0
        case 4:
            return prize?.data.count ?? 0
        case 5:
            return prize?.extra.count ?? 0
        default:
            return   0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopPlayerCell.identifier, for: indexPath) as? TopPlayerCell else {
                fatalError()
            }
            if let payment = payment{
                cell.bind(with: payment)
            }
            cell.onCampaign = {[weak self] campaign in
                guard let self = self else {return}
                self.campaignID = campaign.id
                self.delegate?.onCampaignChange(campaign)
            }
            return cell
        }else if indexPath.section == 1{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Top3RankCell.identifier, for: indexPath) as? Top3RankCell else {
                fatalError()
            }
            cell.bind(with: top3Rank!)
            return cell
        }else if indexPath.section == 2{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyRankCell.identifier, for: indexPath) as? MyRankCell else{
                fatalError()
            }
            cell.bind(with: userRank!,isDaily: campaignID == 1 ? true : false)
            cell.layoutSubviews()
            return cell
        }else if indexPath.section == 3{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RankCell.identifier, for: indexPath) as?  RankCell else {
                fatalError()
            }
            let obj = allUserRank![indexPath.row]
            cell.bind(with: obj)
            return cell
        }else if indexPath.section == 4{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PrizeCell.identifier, for: indexPath) as? PrizeCell else{
                fatalError()
            }
            
            let obj = prize?.data[indexPath.row]
            cell.bind(with : obj,rank: indexPath.row + 1)
            return cell
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CampaignDetailsCell.identifier, for: indexPath) as? CampaignDetailsCell else{
            fatalError()
        }
        Log.info("\(indexPath.row), \(indexPath.section), \(prize?.extra.count)")
        if let obj = prize?.extra[indexPath.row]{
            cell.titleLabel.text = obj.title
        }
        
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return .zero
        }else if section == 3{
            return .init(top: 16, left: 0, bottom: 16, right: 0)
        }else if section == 4{
            return .init(top: 8, left: 0, bottom: 16, right: 0)
        }else{
            return .init(top: 16, left: 0, bottom: 0, right: 0)
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.bounds.width
        if indexPath.section == 0{
            return .init(width: w - 32, height: TopPlayerCell.height)
        }else if indexPath.section ==  1{
            return .init(width: w - 16, height: Top3RankCell.height)
        }
        else if indexPath.section ==  2{
            var offset : CGFloat = 0
            if let _ = userRank?.dailyStreamRemaining, let _ = userRank?.totalBonusRemaining{
               offset = 0
            }else{
                offset = 20
            }
            if campaignID == 3 {
                offset = 30
            }
            return .init(width: w - 32, height: MyRankCell.height - offset)
        }
        else if indexPath.section == 3{
            return .init(width: w - 32, height: RankCell.HEIGHT)
        }else if indexPath.section == 4{
            return .init(width: w - 32, height: 120)
        }else if indexPath.section == 5{
            return .init(width: w - 32, height: CampaignDetailsCell
                .HEIGHT)
            
        }
        return .zero
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return  8
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader{
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Header.identifier, for: indexPath) as? Header else {
                fatalError()
            }
            
            if indexPath.section == 4{
                header.ttitleLabel.text = "Prizes for Winners"
            }else{
                header.ttitleLabel.text = "Terms & Conditions"
            }
            return header
                    
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if prize == nil {
            return .zero
        }
        if section == 4 || section == 5{
            return .init(width: collectionView.bounds.width - 32, height: 40)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 2{
            if let img = userRank?.imageURL, img.count > 0{
                return
            }
            self.delegate?.onMyRankPressed()
        }else if indexPath.section == 5{
            let obj = prize?.extra[indexPath.row]
            if let obj = obj {
                self.delegate?.onTermsAndConditionPressed(url: obj.url)
            }
            
        }
    }
}
