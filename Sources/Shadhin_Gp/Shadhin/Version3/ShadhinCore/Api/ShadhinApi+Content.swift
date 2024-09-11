//
//  ShadhinApi+ContentCommon.swift
//  Shadhin
//
//  Created by Gakk Alpha on 7/27/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation


extension ShadhinApi{
    
    func getAlbumOrPlaylistOrSingleDataById(
        ContentID: String,
        mediaType: SMContentType,
        completion: @escaping (_ data: [CommonContentProtocol]?,Error?,_ image : String? )-> Void,
        imageCompletion: ((String?)->Void)? = nil,
        isPaidComletion: ((Bool?)->Void)? = nil )
    {
        guard (mediaType == .album || mediaType == .playlist || mediaType == .song) else{
            return Log.warning("unsupported SMContentType:\(mediaType) was called on getAlbumOrPlaylistOrSingleDataById")
        }
        AF.request(
            GET_ALBUM_PLAYLIST(mediaType,ContentID),
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseData{ response in
            switch response.result{
            case let .success(data):
                if mediaType == .song,
                   let track = try? JSONDecoder().decode(SingleTrackDetailsObj.self, from: data){
                    var data = [CommonContentProtocol]()
                    data.append(track.data)
                    completion(data, nil, track.data.image)
                }else if let contentData = try? JSONDecoder().decode(AlbumOrPlaylistObj.self, from: data) {
                    imageCompletion?(contentData.image)
                    isPaidComletion?(contentData.isPaid)
                    completion(contentData.data,nil, contentData.image)
                }else{
                    let error = NSError(domain: "shadhin.com", code: 0, userInfo: [NSLocalizedDescriptionKey: "experiencing technical problems now which will be fixed soon.Thanks for your patience."])
                    completion(nil, error, nil)
                }
            case .failure(_):
                let error = NSError(domain: "", code: 400, userInfo: [ NSLocalizedDescriptionKey: "experiencing technical problems now which will be fixed soon.Thanks for your patience."])
                completion(nil,error,"experiencing technical problems now which will be fixed soon.Thanks for your patience.")
            }
        }
    }
    
    func getContentLikeCount(
        contentID: String,
        contentType: String, //for PD needs full string
        completion: @escaping (Int, String, String)->Void)
    {
        AF.request(
            GET_FAV_COUNT(contentID,contentType),
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseData{ response in
            switch response.result{
            case let .success(data):
                if let data = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
                   let data0 = data["data"] as? [String : Any],
                   let count = data0["TotalFav"] as? Int{
                    completion(count, contentID, contentType)
                }else{
                    completion(0, contentID, contentType)
                }
            case let .failure(error):
                completion(0, contentID, contentType)
                Log.error(error.localizedDescription)
            }
        }
    }
    
    @available(*, deprecated, message: "data in get songs by artist id")
    func getMonthlyListenerCount(
        contentID: String,
        type: SMContentType = .artist,
        completion: @escaping (Int)->Void){
            guard type == .artist || type == .album || type == .playlist else { return Log.error("Wrong type called on api")}
            AF.request(
                GET_MONTHLY_LISTENER_COUNT(contentID,type.rawValue),
                method: .get,
                parameters: nil,
                encoding: JSONEncoding.default,
                headers: API_HEADER
            ).responseData { response in
                switch response.result{
                case let .success(data):
                    if let data = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
                       let data0 = data["data"] as? [String : Any],
                       let count = data0["TotalPlayCount"] as? Int{
                        completion(count)
                    }else{
                        completion(0)
                    }
                case let .failure(error):
                    completion(0)
                    Log.error(error.localizedDescription)
                }
            }
        }
    
}
