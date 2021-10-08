//
//  Utils.swift
//  pgpt1
//
//  Created by Arthur Fayzrakhmanov on 08.10.2021.
//

import Foundation

let rsaPubKeyAttrs: [String: Any] =
[kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
 kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
 kSecAttrKeySizeInBits as String: 2048]

func pubKey(from string: String, _ attributes: [String: Any]) -> SecKey? {
    var error: Unmanaged<CFError>?
    guard let key = SecKeyCreateWithData(
        Data(
            base64Encoded: string.data(using: .utf8)!)! as CFData,
        attributes as CFDictionary,
        &error
    )
    else {
        print("Key reconstruction error")
        let e =  error!.takeRetainedValue() as Error
        print(e.localizedDescription)
        return nil
    }
    return key
}

func messageSizeValid(withKey key: SecKey, message: String) -> Bool {
    message.count < (SecKeyGetBlockSize(key)-130)
}


func rsaEncode(withKey key: SecKey, message: String) -> Data? {
    guard messageSizeValid(withKey: key, message: message) else {
        print("Invalid message size")
        return nil
    }
    var error: Unmanaged<CFError>?
    guard let cipherText = SecKeyCreateEncryptedData(
        key,
        .rsaEncryptionPKCS1,
        message.data(using: .utf8)! as CFData,
        &error) as Data?
    else {
            print("Key import error")
            let e =  error!.takeRetainedValue() as Error
            print(e.localizedDescription)
            return nil
        }
    return cipherText
}
