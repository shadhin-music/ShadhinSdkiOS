//
//  StripeStatusResponse.swift
//  Shadhin
//
//  Created by Joy on 29/5/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import Foundation

struct StripeStatusResponse: Codable {
    let statusCode: Int
    let message: String
    let data: [StripeStatus]
}

// MARK: - Datum
struct StripeStatus: Codable {
    let status, productID, subscriptionID: String

    enum CodingKeys: String, CodingKey {
        case status
        case productID = "productId"
        case subscriptionID = "subscriptionId"
    }
}
