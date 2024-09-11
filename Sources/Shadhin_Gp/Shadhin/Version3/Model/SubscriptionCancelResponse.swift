//
//  SubscriptionCancelResponse.swift
//  Shadhin
//
//  Created by Joy on 22/5/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import Foundation
// MARK: - SubscriptionCancelResponse
struct SubscriptionCancelResponse: Codable {
    let statusCode: Int
    let message: String
    let data: SubscriptionInfo?
}

// MARK: - DataClass
struct SubscriptionInfo: Codable {
    let id: String
    let cancelAt: Int
    let cancelAtPeriodEnd: Bool
    let canceledAt: Int
    let collectionMethod: String
    let created: Int
    let currency, msisdn, userCode, customerID: String
    let customerEmail, description: String
    let endedAt, startDate: Int
    let status, cancelStatus, paymentStatus: String
    let updated: Int
    let stripeProductID, productID, chargeID, subscriptionID: String
    let invoiceID: String
    let currentPeriodEnd, currentPeriodStart: Int

    enum CodingKeys: String, CodingKey {
        case id, cancelAt, cancelAtPeriodEnd, canceledAt, collectionMethod, created, currency, msisdn, userCode
        case customerID = "customerId"
        case customerEmail, description, endedAt, startDate, status, cancelStatus, paymentStatus, updated
        case stripeProductID = "stripeProductId"
        case productID = "productId"
        case chargeID = "chargeId"
        case subscriptionID = "subscriptionId"
        case invoiceID = "invoiceId"
        case currentPeriodEnd, currentPeriodStart
    }
}
