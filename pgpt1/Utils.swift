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
    let keyBytes = string.data(using: .utf8)
    guard let keyBytes = keyBytes,
          let keyBase64 = Data(base64Encoded: keyBytes),
          let key = SecKeyCreateWithData(
            keyBase64 as CFData,
            attributes as CFDictionary,
            &error
          )
    else {
        print("Key reconstruction error")
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
        let e =  error!.takeRetainedValue() as Error
        print(e.localizedDescription)
        return nil
    }
    return cipherText
}


func rsaDecode(withKey key: SecKey, message encoded: Data) -> Data? {
    var error: Unmanaged<CFError>?
    return SecKeyCreateDecryptedData(key,
                                     .rsaEncryptionPKCS1,
                                     encoded as CFData,
                                     &error) as Data?
}

func userKeyAlias(username: String?) -> String {
    "com.example.keys.\(username ?? "no_user")_key"
}

func usernameIsEmpty(username: String) -> Bool {
    usernameTrimmed(username: username).isEmpty
}

func usernameTrimmed(username: String?) -> String {
    guard let usernameUnwrapped = username else { return "" }
    return usernameUnwrapped.trimmingCharacters(in: .whitespaces)
}
