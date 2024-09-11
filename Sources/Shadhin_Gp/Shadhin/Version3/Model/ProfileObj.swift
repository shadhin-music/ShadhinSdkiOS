//
//  ProfileDTO.swift
//  Shadhin
//
//  Created by Gakk Alpha on 7/14/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

// MARK: - ProfileDTO
struct ProfileObj: Codable {
    let status: String?
    let message: String
    let data: DataClass?

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case message = "Message"
        case data = "Data"
    }
    
    // MARK: - DataClass
    struct DataClass: Codable {
        let userFullName: String?
        let phoneNumber: String?
        let birthDate: String?
        let gender, country, countryCode, city: String?
        let userPic: String?
        let registerWith: [String]

        enum CodingKeys: String, CodingKey {
            case userFullName = "UserFullName"
            case phoneNumber = "PhoneNumber"
            case birthDate = "BirthDate"
            case gender = "Gender"
            case country = "Country"
            case countryCode = "CountryCode"
            case city = "City"
            case userPic = "UserPic"
            case registerWith = "RegisterWith"
        }
    }

}

// MARK: - LoginModel
struct ProfileObjNew: Codable {
    let status, message: String
    let data: DataClasseNew?

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case message = "Message"
        case data = "Data"
    }
}

// MARK: - DataClass
struct DataClasseNew: Codable {
    let token, rowid, msisdn, userName: String
    let userCode: String
    let userFullName: JSONNull?
    let imageURL: String
    let imageSource, emailID: String
    let appleID: JSONNull?
    let facebookID: String
    let googleID, linkedinID, twitterID: JSONNull?
    let gender, country, countryCode: String
    let registerWith: [String]
    let registrationDate, birthDate, city: String
    let hasFavoriteArtist, hasFavoriteGenre: Bool

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
