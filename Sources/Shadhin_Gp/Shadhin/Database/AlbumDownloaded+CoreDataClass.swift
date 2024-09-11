//
//  AlbumDownloaded+CoreDataClass.swift
//  
//
//  Created by Admin on 26/6/22.
//
//

import Foundation
import CoreData

@objc(AlbumDownloaded)
public class AlbumDownloaded: NSManagedObject {
    func getContentProtocal()-> CommonContent_V7{
        var content = CommonContent_V7()
        content.albumID = self.albumID
        content.artist = self.artist
        content.artistID = self.artistID
        content.contentID = self.contentID
        content.contentType = self.contentType
        //content.releaseDate = self.date
        //content.msisdn = self.msisdn
        content.image = self.imageURL
        content.title = self.title
        content.isDownloading = self.isDownloading
        content.date = self.date
        return content
    }
    func setData(with content : CommonContent_V7){
        self.albumID = (content.albumID != nil && !content.artist!.isEmpty) ? content.albumID : content.contentID
        self.artist = content.artist
        self.artistID = content.artistID
        self.contentID = content.contentID
        self.contentType = content.contentType
        self.imageURL = content.image
        self.title = content.title
        self.msisdn = ShadhinCore.instance.defaults.userIdentity
        self.isDownloading = true
        self.date = Date()
    }
    func setData(with content : CommonContentProtocol){
        self.albumID = (content.albumID != nil && !content.artist!.isEmpty) ? content.albumID : content.contentID
        self.artist = content.artist
        self.artistID = content.artistID
        self.contentID = content.contentID
        self.contentType = content.contentType
        self.imageURL = content.image
        self.title = content.title
        self.msisdn = ShadhinCore.instance.defaults.userIdentity
        self.isDownloading = true
        self.date  = Date()
    }
}
