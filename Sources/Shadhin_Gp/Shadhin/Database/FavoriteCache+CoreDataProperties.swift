//
//  FavoriteCache+CoreDataProperties.swift
//  
//
//  Created by Gakk Alpha on 8/29/22.
//
//

import Foundation
import CoreData


extension FavoriteCache: CommonContentProtocol {
    var artistImage: String? {
        get {
            return ""
        }
        set {
           
        }
    }
    
    public var playCount: Int? {
        get {
            Int(playCount_)
        }
        set {
            if let value = newValue{
                playCount_ = Int32(value)
            }
        }
    }
    
    
    public var isPaid: Bool? {
        get {
            isPaid_
        }
        set {
            if let value = newValue{
                isPaid_ = value
            }
        }
    }
    
    public var smContentType: SMContentType{
        get{
            SMContentType.init(rawValue: contentType)
        }
    }
    

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteCache> {
        return NSFetchRequest<FavoriteCache>(entityName: "FavoriteCache")
    }

    @NSManaged public var followers: String?
    @NSManaged public var teaserUrl: String?
    @NSManaged public var hasRBT: Bool
    @NSManaged public var releaseDate: String?
    @NSManaged public var labelname: String?
    @NSManaged public var copyright: String?
    @NSManaged public var isPaid_: Bool
    @NSManaged public var trackType: String?
    @NSManaged public var playCount_: Int32
    @NSManaged public var fav: String?
    @NSManaged public var contentType: String?
    @NSManaged public var crudDate: Date
    @NSManaged public var duration: String?
    @NSManaged public var albumID: String?
    @NSManaged public var artistID: String?
    @NSManaged public var artist: String?
    @NSManaged public var playUrl: String?
    @NSManaged public var title: String?
    @NSManaged public var newBannerImg: String?
    @NSManaged public var image: String?
    @NSManaged public var contentID: String?
    

}
