//
//  RecentlyPlayedResponse.swift
//  Shadhin
//
//  Created by Joy on 24/7/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation
struct RecentlyPlayedObj: Codable {
    let status, message: String
    let data: [RecentlyPlayedModel]
    let total: Int
    let type, fav, image, follow: String?
}

// MARK: - Datum
struct RecentlyPlayedModel: Codable {
    let contentID: String
    let image: String
    let title, contentType, playURL, artistID: String
    let artist, albumID, duration, fav: String

    enum CodingKeys: String, CodingKey {
        case contentID = "ContentId"
        case image = "Image"
        case title = "Title"
        case contentType = "ContentType"
        case playURL = "PlayUrl"
        case artistID = "ArtistId"
        case artist = "Artist"
        case albumID = "AlbumId"
        case duration = "Duration"
        case fav
    }
    
    func getDatabaseContentModel()-> CommonContent_V7{
        var dcm = CommonContent_V7()
        dcm.contentID = self.contentID
        dcm.image = self.image
        dcm.title = self.title
        dcm.contentType = self.contentType
        dcm.playUrl = self.playURL
        dcm.artistID = self.artistID
        dcm.artist = self.artist
        dcm.albumID = self.albumID
        dcm.duration = self.duration
        dcm.fav = self.fav
        return dcm
    }
}

