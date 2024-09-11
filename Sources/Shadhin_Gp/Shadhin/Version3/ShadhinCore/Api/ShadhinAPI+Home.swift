//
//  ShaadhinAPI+Home.swift
//  Shadhin
//
//  Created by Gakk Alpha on 12/10/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import Foundation

extension ShadhinApi{
    class Home{
        private static let GET_PAGED_HOME = {(
            _ page: String)->String in
            return ShadhinApiURL().GET_PAGED_HOME_CONTENT(page)
        }
        private static let GET_RECOMANDED = "https://coreapi.shadhinmusic.com/api/v6/Recommendation/Patches"
        
        static func getHome(
            by page : Int,
            completion : @escaping (HomeResponse?, Error?) -> Void)
        {
            AF.request(
                GET_PAGED_HOME("\(page)"),
                method: .get,
                encoding: JSONEncoding.default,
                headers: ShadhinApiContants().API_HEADER
               // interceptor: RetryInterceptor(, networkErrorProtocol: )
            )
            .validate()
            .responseDecodable(of: HomeResponse.self){ response in
                switch response.result{
                case let .success(data):
                    completion(data,nil)
                    try? Disk.save(data, to: .caches, as: self.GET_PAGED_HOME("\(page)"))
                case .failure(_):
                    // print("My error",error)
                    if Disk.exists(self.GET_PAGED_HOME("\(page)"), in: .caches),
                       let homeResponse = try? Disk.retrieve(self.GET_PAGED_HOME("\(page)"), from: .caches, as: HomeResponse.self){
                        completion(homeResponse,nil)
                    }else{
                        let error = NSError(domain: "", code: 400, userInfo: [ NSLocalizedDescriptionKey: "experiencing technical problems now which will be fixed soon.Thanks for your patience."])
                        completion(nil,error)
                    }
                }
            }
        }
        
        static func getRecomandedHome(completion : @escaping (HomeResponse?, Error?) -> Void){
            AF.request(
                GET_RECOMANDED,
                method: .get,
                encoding: JSONEncoding.default,
                headers: ShadhinApiContants().API_HEADER
             //   interceptor: RetryInterceptor()
            ).validate().responseDecodable(of: HomeResponse.self){ response in
                switch response.result{
                case let .success(data):
                    completion(data,nil)
                    try? Disk.save(data, to: .caches, as: GET_RECOMANDED)
                case .failure(let err):
                    let error = NSError(domain: "", code: 400, userInfo: [ NSLocalizedDescriptionKey: "experiencing technical problems now which will be fixed soon.Thanks for your patience."])
                    completion(nil,error)
                    Log.error(err.localizedDescription)
                }
            }.responseString { respose in
                if let str = respose.value {
                    Log.info(str)
                }
            }
        }
    }
    
    static func getAIMoods(completion: (@escaping (Result<AIMoodlistModel,AFError>)->Void)){
        AF.request(
            ShadhinApiURL.GET_AI_MOOD_LIST,
            method: .get,
            encoding: JSONEncoding.default,
            headers: ShadhinApiContants().API_HEADER
//            interceptor: RetryInterceptor()
        ).validate().responseDecodable(of: AIMoodlistModel.self){ response in
            completion(response.result)
        }
    }
    
    static func getAIGeneratedPlayList(moodId: String, userCode: String, completion: (@escaping (Result<AIPlaylistResponseModel,AFError>)->Void)){
        print(ShadhinApiURL.GET_AI_GENERATED_PLAY_LIST(moodId, userCode))
        AF.request(
            ShadhinApiURL.GET_AI_GENERATED_PLAY_LIST(moodId, userCode),
            method: .get,
            encoding: JSONEncoding.default,
            headers: ShadhinApiContants().API_HEADER
          //  interceptor: RetryInterceptor()
        ).validate().responseDecodable(of: AIPlaylistResponseModel.self){ response in
            completion(response.result)
        }
    }
    
    
    func getUserInfo(token: String, completion: (@escaping (Result<UserInfoResponseModel,AFError>)->Void)){
        AF.request(
            GET_USER_INFO,
            method: .get,
            encoding: JSONEncoding.default,
            headers: getAPIHeaderForUserInfo(token: token)
        ).validate().responseDecodable(of: UserInfoResponseModel.self){ response in
            completion(response.result)
        }
    }
}


