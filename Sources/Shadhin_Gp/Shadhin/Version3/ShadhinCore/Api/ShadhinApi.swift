//
//  ApiCore.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/24/21.
//  Copyright © 2021 Cloud 7 Limited. All rights reserved.
//

import UIKit


var AF = Session.default

public class ShadhinApi : ShadhinApiURL{
    static let cancel_secretKey = "secretKeyb1DEYmhXrTYiyU65EWI8U1h"
    static let cancel_iv_secret = "ivSec1HJFhYrhcr5"
    override init() {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        let configuration = URLSessionConfiguration.default
        var defaultHeaders = HTTPHeaders.default
        defaultHeaders.add(name: "device-name", value: "\(UIDevice.modelName)")
        defaultHeaders.add(name: "app-version", value: "iOS-\(version)")
        defaultHeaders.add(name: "user-id",     value: "\(ShadhinDefaults().userIdentity)")
        defaultHeaders.add(name: "countryCode", value: ShadhinDefaults().geoLocation.lowercased())
        configuration.headers = defaultHeaders
        // AF = Session(configuration: configuration, interceptor: RetryInterceptor())
    }
    
    
    public func getStreamingPoints(
        completion  : @escaping (_ isSuccess: Bool, _ totalCount: String?)->Void)
    {
        AF.request(STREAM_POINTS, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: API_HEADER).responseData { response in
            switch response.result{
            case .success(let data):
                if let json = try? JSONSerialization.jsonObject(with: data),
                   let value = json as? [String : Any],
                   let point = value["Data"] as? Int{
                    return completion(true, "\(point)")
                } else {
                    return completion(true, "Unknown")
                }
            case .failure(let error):
                Log.error(error.localizedDescription)
                return completion(false,"We are experiencing technical problems now which will be fixed soon.Thanks for your patience.")
            }
        }
    }
    
    public func removeSocialCredentials(
        completion  : @escaping (_ isSuccess: Bool)->Void)
    {
        AF.request(REMOVE_SOCIAL, method: .post, encoding: JSONEncoding.default, headers: API_HEADER).responseData { response in
            if response.response?.statusCode == 200{
                completion(true)
            }else{
                completion(false)
            }
        }
    }
    
    func getTopTenTrendingData(
        type        : String,
        completion  : @escaping (_ data: TopTenTrendingObj?,Error?)-> Void)
    {
        AF.request(TOP_TEN_TRENDING(type), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: API_HEADER).responseDecodable(of: TopTenTrendingObj.self) { response in
            switch response.result {
            case let .success(data):
                completion(data,nil)
            case .failure(_):
            let error = NSError(domain: "", code: 400, userInfo: [ NSLocalizedDescriptionKey: "experiencing technical problems now which will be fixed soon.Thanks for your patience."])
                completion(nil,error)
            }
        }
    }
    
    //get image url
    static func getImageUrl(url : String,size : Int)-> URL?{
        let urlString = url.replacingOccurrences(of: "<$size$>", with: "\(size)")
        return URL(string: urlString.safeUrl())
    }
    
}
