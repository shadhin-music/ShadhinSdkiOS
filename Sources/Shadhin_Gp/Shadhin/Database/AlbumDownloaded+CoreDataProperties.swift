//
//  AlbumDownloaded+CoreDataProperties.swift
//  
//
//  Created by Admin on 26/6/22.
//
//

import Foundation
import CoreData


extension AlbumDownloaded {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AlbumDownloaded> {
        return NSFetchRequest<AlbumDownloaded>(entityName: "AlbumDownloaded")
    }

    @NSManaged public var albumID: String?
    @NSManaged public var artist: String?
    @NSManaged public var artistID: String?
    @NSManaged public var contentID: String?
    @NSManaged public var contentType: String?
    @NSManaged public var date: Date?
    @NSManaged public var imageURL: String?
    @NSManaged public var title: String?
    @NSManaged public var isDownloading: Bool
    @NSManaged public var msisdn: String?

}
