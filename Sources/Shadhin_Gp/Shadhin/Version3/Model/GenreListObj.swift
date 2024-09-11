//
//  GenreListObj.swift
//  Shadhin
//
//  Created by Maruf on 5/11/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import Foundation

class GetGenreListobj: Codable {
    let data: [GenreData]
    let statusCode: Int
    let message: String

    enum CodingKeys: String, CodingKey {
        case data = "data"
        case statusCode = "StatusCode"
        case message = "message"
    }
    
    class GenreData: Codable {
        let id: Int?
        let genreName: String?
        var isFavorite: Bool?
        let imageURL: String?
        var isActive: Bool?

        enum CodingKeys: String, CodingKey {
            case id = "Id"
            case genreName = "GenreName"
            case isFavorite = "IsFavorite"
            case imageURL = "ImageUrl"
            case isActive = "IsActive"
        }
        
        func getData() -> [String: Any]{
            return [
                    "Id": id ?? -1,
                    "GenreName": genreName ?? "",
                    "IsFavorite": true,
                    "IsActive": true
                ]
        }
    }
}
