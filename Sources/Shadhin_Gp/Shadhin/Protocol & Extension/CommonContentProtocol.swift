//
//  ContentDataProtocol.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 7/10/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import Foundation

protocol CommonContentProtocol {
    var contentID: String? {get set}
    var image: String? {get set}
    var newBannerImg: String? {get set}
    var title: String? {get set}
    var playUrl: String? {get set}
    var artist: String? {get set}
    var artistID: String? {get set}
    var albumID: String? {get set}
    var artistImage : String? {get set}
    var duration: String? {get set}
    var contentType: String? {get set}
    var fav: String? {get set}
    var playCount : Int?{get set}
    
    var trackType : String?{get set}
    var isPaid : Bool?{get set}
    var copyright: String? {get set}
    
    var labelname: String? {get set}
    var releaseDate: String? {get set}
    
    var hasRBT: Bool{get set}
    
    var teaserUrl : String? {get set}
    var followers : String? {get set}
    func getRoot()-> RootModel
}


extension CommonContentProtocol{
    func getRoot()-> RootModel{
        return .init(contentID: contentID ?? "", contentType: contentType ?? "")
    }
}
struct RootModel : Equatable{
    var contentID : String
    var contentType : String
}
