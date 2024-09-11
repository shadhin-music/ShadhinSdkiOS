//
//  SongsDownload+CoreDataProperties.swift
//  
//
//  Created by Admin on 23/6/22.
//
//

import Foundation
import CoreData


extension SongsDownload {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SongsDownload> {
        return NSFetchRequest<SongsDownload>(entityName: "SongsDownload")
    }

    @NSManaged public var albumID: String?
    @NSManaged public var artist: String?
    @NSManaged public var artistID: String?
    @NSManaged public var contentID: String?
    @NSManaged public var contentType: String?
    @NSManaged public var date: Date?
    @NSManaged public var duration: String?
    @NSManaged public var favs: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var msisdn: String?
    @NSManaged public var playURL: String?
    @NSManaged public var title: String?
    @NSManaged public var isSingleDownload: Bool

}
