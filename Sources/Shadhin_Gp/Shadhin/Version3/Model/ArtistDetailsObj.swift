//
//  ArtistModel.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/16/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import Foundation

struct ArtistTracks: Codable {
    var fav: String
    var data: [CommonContent_V2]
    var image: String
    var follow: String
    var MonthlyListener : String?
}

struct ArtistBioObj: Codable {
    var data: Data
    
    struct Data: Codable {
        var bio: Bio
    }

    struct Bio: Codable {
        var summary: String
    }
}


