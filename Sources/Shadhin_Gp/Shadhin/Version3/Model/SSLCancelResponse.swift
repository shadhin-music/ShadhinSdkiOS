//
//  SSLCancelResponse.swift
//  Shadhin
//
//  Created by Joy on 6/6/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import Foundation

struct SSLCancelResponse: Codable {
    let status: Bool
    let message: String?
    let data: String?
}
