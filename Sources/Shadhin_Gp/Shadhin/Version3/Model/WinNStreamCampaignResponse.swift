//
//  WinNStreamCampaignResponse.swift
//  Shadhin
//
//  Created by Joy on 15/2/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import Foundation

struct StreamNwinCampaignResponse: Codable {
    let status, message, type: String
    let fav: String?
    let data: [CampaignProvider]
    let image, follow: String?
    let isPaid: Bool
    let name: String?
}

// MARK: - Datum
struct CampaignProvider: Codable {
    let name: String
    let paymentMethods: [PaymentMethod]

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case paymentMethods = "PaymentMethods"
    }
}

// MARK: - PaymentMethod
struct PaymentMethod: Codable {
    let id: Int
        let name: String
        let url: String?
        let prizeTitle: String?
        let prizeURL: String?
        let startDate, endDate: String
        let paymentServices: [PaymentService]
        let campaignSegments: [CampaignSegment]

        enum CodingKeys: String, CodingKey {
            case id = "Id"
            case name = "Name"
            case url = "TermsAndCondition"
            case prizeTitle = "PrizeTitle"
            case prizeURL = "PrizeUrl"
            case startDate = "StartDate"
            case endDate = "EndDate"
            case paymentServices = "PaymentServices"
            case campaignSegments = "CampaignSegments"
        }
}

// MARK: - CampaignSegment
struct CampaignSegment: Codable {
    let id: Int
    let name: Name

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
    }
}

// MARK: - PaymentService
struct PaymentService: Codable {
    let paymentMethodID: Int?
    let serviceID: String

    enum CodingKeys: String, CodingKey {
        case paymentMethodID = "PaymentMethodId"
        case serviceID = "ServiceId"
    }
}


enum Name: String, Codable {
    case daily = "Daily"
    case monthLy = "MonthLy"
    case weekly = "Weekly"
}

enum PaymentGetwayType : String {
    case GP = "GP"
    case BL = "BL"
    case ROBI = "ROBI"
    case SSL = "SSL"
    case Bkash = "BKASH"
    case Nagad = "NAGAD"
}
