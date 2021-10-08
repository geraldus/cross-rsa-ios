//
//  Utils.swift
//  pgpt1
//
//  Created by Arthur Fayzrakhmanov on 30.09.2021.
//

import Foundation

func getPublicKeyString(key: SecKey) -> String? {
    let publicKeyCopy = SecKeyCopyPublicKey(key)!
    var result: String? = nil
    do {
        var error: Unmanaged<CFError>?
        guard let secKeyExport = SecKeyCopyExternalRepresentation(publicKeyCopy, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        let pubData = secKeyExport as Data?
        result = pubData!.base64EncodedString()
    } catch {
        print("Error getting public key copy")
    }
    return result
}
