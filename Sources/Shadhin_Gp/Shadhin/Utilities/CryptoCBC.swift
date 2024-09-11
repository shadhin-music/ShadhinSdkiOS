//
//  Crypto.swift
//  Shadhin
//
//  Created by Gakk Alpha on 1/5/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class CryptoCBC{
    
    static let KEY = "AlongSecrectKeyG"
    static let IV = "qpoUHiRDLgkAliep"
    
    static let shared = CryptoCBC()
    
    private init(){}
    
    func encryptMessage(message: String, encryptionKey: String = KEY, iv: String = IV) -> String? {
        if let aes = try? AES(key: encryptionKey, iv: iv),
           let encrypted = try? aes.encrypt(Array<UInt8>(message.utf8)) {
            return encrypted.toBase64()
        }
        return nil
    }
    
    func decryptMessage(encryptedMessage: String, encryptionKey: String = KEY, iv: String = IV) -> String? {
        
        guard isBase64Encoded(value: encryptedMessage) else{
            return encryptedMessage
        }
        
        if let aes = try? AES(key: encryptionKey, iv: iv), let data = Data(base64Encoded: encryptedMessage),
           let decrypted = try? aes.decrypt(Array<UInt8>(data)) {
            return String(data: Data(decrypted), encoding: .utf8)
        }
        return nil
    }
    
    func isBase64Encoded(value : String) -> Bool{
        let base64Regex = "^(?:[A-Za-z0-9+\\/]{4})*(?:[A-Za-z0-9+\\/]{2}==|[A-Za-z0-9+\\/]{3}=)?$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", base64Regex)
        return predicate.evaluate(with: value)
    }
}
