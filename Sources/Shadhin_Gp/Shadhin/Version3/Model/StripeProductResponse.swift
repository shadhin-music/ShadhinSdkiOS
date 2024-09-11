//
//  StripeProductResponse.swift
//  Shadhin
//
//  Created by Joy on 21/5/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import Foundation

struct StripeProductItem: Codable {
    let id, name, stripeProductID, currency: String
    let unitAmount: Double
    let isAlreadySubscribe: Bool

    enum CodingKeys: String, CodingKey {
        case id, name
        case stripeProductID = "stripeProductId"
        case currency, unitAmount, isAlreadySubscribe
    }
    
//    func getSubscription()-> Subscription{
//        return .init(subsTime: name.capitalizeFirstLetter(), currency: "USD", price: "\(unitAmount)", totalDays: "", subTitle: "\(name.capitalizeFirstLetter())", description: "VAT+SD+SC Excluded • Auto-renewal", serviceId: "\(id)")
//    }
}

typealias StripeProductResponse = [StripeProductItem]
