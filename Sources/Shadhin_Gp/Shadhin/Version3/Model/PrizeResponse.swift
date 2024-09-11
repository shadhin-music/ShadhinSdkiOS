//
//  PrizeResponse.swift
//  Shadhin
//
//  Created by Joy on 22/2/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import Foundation

// MARK: - CampaignResponseElement
struct PrizeResponse: Codable {
    let data: [PrizeModel]
    let extra: [Extra]
    let leaderBoardImage : [String]?
    let paymentPartner: String

    enum CodingKeys: String, CodingKey {
        case data = "Data"
        case extra = "Extra"
        case leaderBoardImage = "LeaderBoardImage"
        case paymentPartner = "Operator"
    }
}

// MARK: - Datum
struct PrizeModel: Codable {
    let title, subTitle: String
    let imageURL: String

    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case subTitle = "SubTitle"
        case imageURL = "ImageUrl"
    }
}

// MARK: - Extra
struct Extra: Codable {
    let id: Int
    let isShow: Bool
    let clientValue: Int
    let title: String
    let url: String
    let extraOperator: String

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case isShow = "IsShow"
        case clientValue = "ClientValue"
        case title = "Title"
        case url = "Url"
        case extraOperator = "Operator"
    }
}

typealias PrizeResponseArr = [PrizeResponse]
