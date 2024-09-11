//
//  VideosDownload+CoreDataProperties.swift
//  
//
//  Created by Admin on 21/6/22.
//
//

import Foundation
import CoreData


extension VideosDownload {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VideosDownload> {
        return NSFetchRequest<VideosDownload>(entityName: "VideosDownload")
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

}
