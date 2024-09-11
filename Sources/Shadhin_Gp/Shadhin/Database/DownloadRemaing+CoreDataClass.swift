//
//  DownloadRemaing+CoreDataClass.swift
//  
//
//  Created by Admin on 23/6/22.
//
//

import Foundation
import CoreData

@objc(DownloadRemaing)
public class DownloadRemaing: NSManagedObject {
    func getContentProtocal()-> CommonContent_V7{
        var content = CommonContent_V7()
        content.albumID = self.albumID
        content.artist = self.artist
        content.artistID = self.artistID
        content.contentID = self.contentID
        content.contentType = self.contentType
        //content.releaseDate = self.date
        //content.msisdn = self.msisdn
        content.duration = self.duration
        content.fav = self.favs
        content.image = self.imageURL
        content.playUrl = self.playURL
        content.title = self.title
        content.playListID = self.playlistID
        content.isSingleDownload = self.isSingleDownload
        return content
    }
    func setData(with content : CommonContent_V7){
        self.albumID = content.albumID
        self.artist = content.artist
        self.artistID = content.artistID
        self.contentID = content.contentID
        self.contentType = content.contentType
        self.duration = content.duration
        self.favs = content.fav
        self.imageURL = content.image
        self.playURL = content.playUrl
        self.title = content.title
        self.msisdn = ShadhinCore.instance.defaults.userIdentity
        self.playlistID = content.playListID
        self.date = Date()
        //self.isSingleDownload = content.isSingleDownload
    }
    func setData(with content : CommonContentProtocol){
        self.albumID = content.albumID
        self.artist = content.artist
        self.artistID = content.artistID
        self.contentID = content.contentID
        self.contentType = content.contentType
        self.duration = content.duration
        self.favs = content.fav
        self.imageURL = content.image
        self.playURL = content.playUrl
        self.title = content.title
        self.msisdn = ShadhinCore.instance.defaults.userIdentity
        self.date = Date()
        //self.isSingleDownload = content.isSingleDownload
    }
}
