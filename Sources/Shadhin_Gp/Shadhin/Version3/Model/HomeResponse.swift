// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? JSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - Welcome
struct HomeResponse: Codable {
    let message: String?
    let data: [HomePatch]?
    let total: Int?
    
    enum CodingKeys: String, CodingKey {
        case message, data, total
    }
}

// MARK: - Datum
struct HomePatch: Codable {
    var rowNumber, patchID: Int?
    var code, title, description: String?
    var designTypeID: Int?
    var image: String?
    var isSeeAllActive, isSuffle: Bool?
    var sort: Int
    var totalPage: Int?
    var contentType: [ContentType]?
    var contents: [Content]
    
    enum CodingKeys: String, CodingKey {
        case rowNumber = "RowNumber"
        case patchID = "PatchId"
        case code = "Code"
        case title = "Title"
        case description = "Description"
        case designTypeID = "DesignTypeId"
        case image = "Image"
        case isSeeAllActive = "IsSeeAllActive"
        case isSuffle = "IsSuffle"
        case sort = "Sort"
        case totalPage = "TotalPage"
        case contentType = "ContentType"
        case contents = "Content"
    }
    
    func getDesign() -> HomePatchType{
        return HomePatchType(rawValue: designTypeID ?? -1) ?? .UNKNOWN
    }
    
    struct ContentType: Codable {
        let contentTypeID: Int?
        let contentTypeName: String?
        let contentType: String?
        let isRadio: Bool?
        
        enum CodingKeys: String, CodingKey {
            case contentTypeID = "ContentTypeId"
            case contentTypeName = "ContentTypeName"
            case contentType = "ContentType"
            case isRadio = "IsRadio"
        }
    }
}

// MARK: - Content
struct Content: Codable, CommonContentProtocol {
    
    var newBannerImg: String? = nil
    var albumID: String?{
        set{
            
        }
        get{
            return "\(self.albumId ?? 0)"
        }
    }
    var albumId : Int?{
        didSet{
            self.albumID = "\(self.albumId ?? 0)"
            Log.info("\(self.albumId ?? 0)")
        }
    }
    var fav: String? = nil
    var playCount: Int? = nil
    var trackType: String?{
        set{
            
        }get{
            return self.type
        }
    }
    var isPaid: Bool? = nil
    var copyright: String? = nil
    var hasRBT: Bool = false
    var teaserUrl: String? = nil
    var followers: String? {
        set{
            
        }
        get{
            return "\(self.follower ?? 0)"
        }
    }
    var contentTypeCode : String?
    var type : String?
    
    var isRadio: Bool?
    var follower: Int?
    var contentID,
        contentType,
        title,
        image,
        releaseDate,
        playUrl,
        artist,
        duration,
        artistID,
        artistImage,
        labelname: String?
    
    enum CodingKeys: String, CodingKey {
        case contentID = "ContentID"
        case contentType = "ContentType"
        case title = "Title"
        case image = "Image"
        case playUrl = "PlayUrl"
        case artist = "Artist"
        case duration = "Duration"
        case artistID = "ArtistId"
        case labelname = "Label"
        case releaseDate = "ReleaseDate"
        case albumId = "AlbumId"
        case teaserUrl = "TeaserUrl"
        case follower = "Follower"
        case contentTypeCode = "ContentTypeCode"
        case isRadio = "IsRadio"
        case type = "Type"
        case artistImage = "ArtistImage"
        case isPaid = "IsPaid"
    }
}

