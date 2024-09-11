//
//  AlbumMyMusic+CoreDataClass.swift
//  
//
//  Created by Gakk Alpha on 6/29/22.
//
//

import Foundation
import CoreData

@objc(AlbumMyMusic)
public class AlbumMyMusic: NSManagedObject {
    func getDatabaseContent()-> CommonContent_V7{
        var data = CommonContent_V7()
        data.contentID = self.contentID
        data.albumID = self.albumID
        data.artist = self.artist
        data.artistID = self.artistID
        data.contentType = self.contentType
        data.image = self.imageURL
        data.title = self.title
        return data
    }
}
