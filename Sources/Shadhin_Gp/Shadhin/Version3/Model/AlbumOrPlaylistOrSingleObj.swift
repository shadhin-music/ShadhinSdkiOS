//
//  AlbumContentModel.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/13/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import Foundation

struct AlbumOrPlaylistObj: Codable {
    var data: [CommonContent_V1]
    var image: String?
    var isPaid: Bool?
}


struct SingleTrackDetailsObj: Codable {
    var data: CommonContent_V2
}
