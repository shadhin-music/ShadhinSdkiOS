//
//  Subscription.swift
//  Shadhin
//
//  Created by Maruf on 15/11/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import Foundation

struct BkashPaymentRequestResponse: Codable{
    let statusCode: Int?
    let message: String?
    let data: DataClass?
    
    // MARK: - DataClass
    struct DataClass: Codable {
        let paymentURL: String
        enum CodingKeys: String, CodingKey {
            case paymentURL = "paymentUrl"
        }
    }

}
