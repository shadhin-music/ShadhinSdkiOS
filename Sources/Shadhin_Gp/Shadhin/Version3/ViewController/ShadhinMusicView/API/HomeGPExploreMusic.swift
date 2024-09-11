//
//  HomeGPExploreMusic.swift
//  Shadhin_Gp
//
//  Created by Maruf on 21/8/24.
//

import Foundation

extension ShadhinApi {
    
    func getHomeGpExplorePatchItem(_ completion : @escaping (_ responseModel: Result<GPExploreMusicModel,AFError> )->()){
        AF.request(
            GP_EXPLORE_MUSICS,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: GPExploreMusicModel.self) { response in
            completion(response.result)
        }
    }
    
}
