//
//  TopStreammingModel.swift
//  ShadhinStory
//
//  Created by Maruf on 14/12/23.
//

import Foundation

struct TopStreammingElementModelData:Codable {
    let data:[TopStreammingElementModel]?
    let statusCode: Int?
    let message: String?
}

// MARK: - Datum
struct TopStreammingElementModel:Codable {
    let contentType: String?
    let contentName: String?
    let minOfStream: Int?
    let imageURL: String?

    enum CodingKeys: String, CodingKey {
        case contentType, contentName, minOfStream
        case imageURL = "imageUrl"
    }
}
