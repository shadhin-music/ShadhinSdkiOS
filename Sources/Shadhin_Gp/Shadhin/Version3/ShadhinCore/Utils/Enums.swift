//
//  Enums.swift
//  Shadhin
//
//  Created by Admin on 12/7/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

enum ContentType : String, Codable{
    case Song = "S"
    case PodCastTrack = "PDBC"
    case PodCastShow = "PDPS"
    case PodCast = "PD"
    case Album = "R"
    case Artist = "AR"
    case Playlist = "P"
    case UserPlaylist = "MP"
    case None
}
enum MoreMenuType : String, CaseIterable{
    case Songs = "S"
    case Album  = "R"
    case Artist = "A"
    case Podcast  =  "PD"
    case PodCastVideo = "VD"
    case Playlist  = "P"
    case UserPlaylist = "UP"
    case Video = "V"
    case None = ""
    //case Download = "Download"
}
enum MoreMenuItemType : String, CaseIterable{
    case Download
    case RemoveDownload = "Remove Download"
    case Favorite
    case RemoveFevorite = "Remove Favorite"
    case Share
    case GotoArtist = "Go To Artist"
    case AddToPlaylist = "Add To Playlist"
    case GotoAlbum = "Go To Album"
    case AddToQuary = "Add To Quary"
    case OpenQueue = "Open Queue"
    case RemoveHistory = "Remove History"
    case WatchLater = "Watch Later"
    case RemoveWatchLater = "Remove Watch Later"
    case Remove
    case ConnectedDevice = "Connected Device"
    case SleepTimer = "Sleep Timer"
    case Speed
}
public enum SMContentType: String, Decodable {
    case LK             = "LK"
    case artist         = "A"
    case album          = "R"
    case song           = "S"
    case podcast        = "PD"
    case podcastVideo   = "VD"
    case video          = "V"
    case playlist       = "P"
    //case subscription   = "SUB"
    case myPlayList     = "MP"
    case unknown
    
    public init(rawValue: String?){
        var value = rawValue?.uppercased() ?? "0"
        if value.starts(with: "PD") || value.starts(with: "VD"),
           value.count > 2{
            value = String(value.prefix(2))
        }
        switch value {
        case "LK": self = .LK
        case "A" : self = .artist
        case "R" : self = .album
        case "S" : self = .song
        case "PD": self = .podcast
        case "VD": self = .podcastVideo
        case "V" : self = .video
        case "P" : self = .playlist
        case "MP": self = .myPlayList
        default  : self = .unknown
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self = SMContentType(rawValue: string) ?? .unknown
    }
}
enum MenuOpenFrom {
    case Download
    case Album
    case Artist
    case Favourit
    case History
    case Podcast
    case RecentPlay
    case Playlist
    case Video
    case UserPlaylist
    case WatchLater
    case Player
}

enum UserActionType{
    case add
    case remove
}

//enum RBTSubDuration: Int{
//    case Monthly = 0
//    case Weekly  = 1
//    case Daily   = 2
//}

enum RBTSubType: Int{
    case OneTime     = 0
    case AutoRenewal = 1
}

enum RegistrationMedium: String{
    case mobile   = "M"
    case email    = "E"
    case facebook = "F"
    case google   = "G"
    case twitter  = "T"
    case linkedIn = "L"
    case apple    = "A"
}

enum UserGender: String{
    case male    = "Male"
    case female  = "Female"
    case unknown = ""
}

enum Telco: String{
    case GrameenPhone = "gp"
    case BanglaLink   = "bl"
    case Robi         = "robi"
    case Airtel       = "airtel"
    case Bkash        = "bkash"
    case Unknown      = "unknown"
    
    init?(rawValue: String) {
        switch rawValue.lowercased(){
        case "gp":
            self = .GrameenPhone
        case "bl":
            self = .BanglaLink
        case "robi":
            self = .Robi
        case "airtel":
            self = .Airtel
        case "bkash":
            self = .Bkash
        default:
            self = .Unknown
        }
    }
}

enum ImageSize: String{
    case BillboardBanner = "596"
    case GpExploreMusic = "116"
}

