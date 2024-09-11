//
//  BLPaymentRequestResponse.swift
//  Shadhin
//
//  Created by Joy on 31/5/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import Foundation
struct BLPaymentRequestResponse: Codable {
    let statusCode: Int?
    let message: String?
}

struct RobiPaymentRequestResponse: Codable {
    let statusCode: Int?
    let message: String?
}

struct RobiDobResponse: Codable {
    let data: DataClass?
    let message: String
    let statusCode: Int

    // Define the nested Data structure
    struct DataClass: Codable {
        let expireAt: String

        enum CodingKeys: String, CodingKey {
            case expireAt = "expireAt"
        }
    }

    enum CodingKeys: String, CodingKey {
        case data = "data"
        case message = "message"
        case statusCode = "statusCode"
    }
}
