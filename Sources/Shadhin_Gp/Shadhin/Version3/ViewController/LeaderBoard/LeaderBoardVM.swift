//
//  LeaderBoardVM.swift
//  Shadhin_BL
//
//  Created by Joy on 11/1/23.
//

import UIKit

protocol LeaderBoardVMProtocol : NSObjectProtocol{
    func userRank(_ rank : RankBkashResponse)
    func allUserRank(_ ranks : [RankBkashResponse])
    func prizeNconditions(prizes : PrizeResponseArr)
    func errorResult(_ error : String)
}

class LeaderBoardVM: NSObject {
    
    private weak var delegate : LeaderBoardVMProtocol?
    
    init(delegate: LeaderBoardVMProtocol? = nil) {
        self.delegate = delegate
    }
    
    func featchData(campaignID : String, date : Date,serviceId : String, provider: String){
        self.getAllUserRank(campaignID: campaignID, date: date,serviceID: ShadhinDefaults().subscriptionServiceID, provider: provider)
    }

    func getAllUserRank(campaignID : String, date : Date,serviceID : String, provider: String){
        ShadhinApi.Leaderboard.getAllUserRank(campaignType: campaignID, serviceId: serviceID, name: provider) { result in
            switch result {
            case .success(let success):
                if let ranks = success.data{
                    self.delegate?.allUserRank(ranks.userStreamingDetailsList)
                    self.delegate?.userRank(ranks.userStreamingDetails)
                }else{
                    self.delegate?.errorResult("All user rank not found")
                }
            case .failure(let failure):
                self.delegate?.errorResult(failure.localizedDescription)
            }
        }
    }
    func bkashUserData(campaignID : String, date : Date, provider: String){
        ShadhinApi.Leaderboard.getBkashUserRanking(campaignID: campaignID,onDate: date, name: provider) { result in
            switch result {
            case .success(let success):
                self.delegate?.userRank(success.data.userStreamingDetails)
                self.delegate?.allUserRank(success.data.userStreamingDetailsList)
            case .failure(let failure):
                self.delegate?.errorResult(failure.localizedDescription)
            }
        }
    }
    func getPrize(campaignType : String){
        ShadhinApi.Leaderboard.getPrize(campaignType: campaignType) { result  in
            switch result {
            case .success(let success):
                self.delegate?.prizeNconditions(prizes: success)
            case .failure(let failure):
                self.delegate?.errorResult(failure.localizedDescription)
            }
        }
    }
}
