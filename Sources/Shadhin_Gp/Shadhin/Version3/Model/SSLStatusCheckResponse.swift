//
//  SSLStatusCheckResponse.swift
//  Shadhin
//
//  Created by Joy on 5/6/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import Foundation

// MARK: - SSLStatusCheckResponse
// MARK: - SSLStatusCheckResponse
struct SSLStatusCheckResponse: Codable {
    let status: Bool
    let message: String?
    let data: SSLStatus?
}

// MARK: - DataClass
struct SSLStatus: Codable {
    let status, serviceID, subscriptionID: String

    enum CodingKeys: String, CodingKey {
        case status
        case serviceID = "serviceId"
        case subscriptionID = "subscriptionId"
    }
}
