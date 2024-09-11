//
//  TokenDTOV5.swift
//  Shadhin
//
//  Created by Gakk Alpha on 7/14/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

// MARK: - TokenDTOV5
public class Tokenv5Obj: NSObject, Codable {
    let message: String
    var isNewUser: Bool?
    var data: DataClass?

    enum CodingKeys: String, CodingKey {
        case message = "Message"
        case isNewUser = "IsNewUser"
        case data = "Data"
    }

    init(message: String,  isNewUser:Bool?, data: DataClass) {
        self.message = message
        self.isNewUser = isNewUser
        self.data = data
    }
    
    class DataClass: Codable {
        let token, userCode: String

        enum CodingKeys: String, CodingKey {
            case token = "Token"
            case userCode = "UserCode"
        }

        init(token: String, userCode: String) {
            self.token = token
            self.userCode = userCode
        }
    }

}


// MARK: - DataClass
public class Tokenv7Obj: NSObject, Codable {
    let status, message: String?
    let data: Data?

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case message = "Message"
        case data = "Data"
    }
    
    init(status: String?, message: String?, data: Data?) {
        self.status = status
        self.message = message
        self.data = data
    }
    
    class Data: Codable {
       var token, rowid, msisdn, userName: String?
       let userCode: String?
       let userFullName: String?
       let imageURL: String?
       let imageSource, emailID: String?
       let appleID: String?
       let facebookID: String?
       let googleID, linkedinID, twitterID: String?
       let gender, country, countryCode: String?
       let registerWith: [String]?
       let registrationDate, birthDate, city: String?
       let hasFavoriteArtist, hasFavoriteGenre: Bool?

        
        init(token: String?, rowid: String?, msisdn: String?, userName: String?, userCode: String?, userFullName: String?, imageURL: String?, imageSource: String?, emailID: String?, appleID: String?, facebookID: String?, googleID: String?, linkedinID: String?, twitterID: String?, gender: String?, country: String?, countryCode: String?, registerWith: [String]?, registrationDate: String?, birthDate: String?, city: String?, hasFavoriteArtist: Bool?, hasFavoriteGenre: Bool?) {
            self.token = token
            self.rowid = rowid
            self.msisdn = msisdn
            self.userName = userName
            self.userCode = userCode
            self.userFullName = userFullName
            self.imageURL = imageURL
            self.imageSource = imageSource
            self.emailID = emailID
            self.appleID = appleID
            self.facebookID = facebookID
            self.googleID = googleID
            self.linkedinID = linkedinID
            self.twitterID = twitterID
            self.gender = gender
            self.country = country
            self.countryCode = countryCode
            self.registerWith = registerWith
            self.registrationDate = registrationDate
            self.birthDate = birthDate
            self.city = city
            self.hasFavoriteArtist = hasFavoriteArtist
            self.hasFavoriteGenre = hasFavoriteGenre
        }
        
       enum CodingKeys: String, CodingKey {
           case token = "Token"
           case rowid = "ROWID"
           case msisdn = "MSISDN"
           case userName = "UserName"
           case userCode = "UserCode"
           case userFullName = "UserFullName"
           case imageURL = "ImageUrl"
           case imageSource = "ImageSource"
           case emailID = "EmailId"
           case appleID = "AppleId"
           case facebookID = "FacebookId"
           case googleID = "GoogleId"
           case linkedinID = "LinkedinId"
           case twitterID = "TwitterId"
           case gender = "Gender"
           case country = "Country"
           case countryCode = "CountryCode"
           case registerWith = "RegisterWith"
           case registrationDate = "RegistrationDate"
           case birthDate = "BirthDate"
           case city = "City"
           case hasFavoriteArtist = "HasFavoriteArtist"
           case hasFavoriteGenre = "HasFavoriteGenre"
       }
        
   }

}

 
