//
//  KeyManagement.swift
//  pgpt1
//
//  Created by Arthur Fayzrakhmanov on 14.09.2021.
//

import SwiftUI

struct KeyItem {
    var key: String
    var item: AnyObject
}

struct KeyManagement: View {
    @State var keys = [String: KeyRep]()
    let x = KeyRep(tag: "123", type: "123")

    var body: some View {
        List {
            ForEach(marshallKeys(), id: \.tag) { k in
                KeyRepView(key: .constant(k))
            }
        }.onAppear() {
            keys = getAllKeyChainItemsOfClass(kSecClassKey as String)
        }
    }

    func marshallKeys() -> [KeyRep] {
        var result: [KeyRep] = []
        keys.forEach { (k, v) in
            result.append(v)
        }
        return result
    }

    func getAllKeyChainItemsOfClass(_ secClass: String) -> [String: KeyRep] {

        let query: [String: Any] = [
            kSecClass as String : secClass,
            kSecReturnData as String  : true,
            kSecReturnAttributes as String : true,
            kSecReturnRef as String : true,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]

        var result: AnyObject?

        let lastResultCode = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        //  this also works, although I am not sure if it is as save as calling withUnsafeMutabePointer
        //  let lastResultCode = SecItemCopyMatching(query as CFDictionary, &result)

        var values = [String: KeyRep]()
        if lastResultCode == noErr {
            let array = result as? Array<Dictionary<String, Any>>

            for item in array! {
                let tag =  String.init(decoding: item[kSecAttrApplicationTag as String] as! Data, as: UTF8.self)
                let secKey = item[kSecValueRef as String] as! SecKey
                let secKeyAttrs = SecKeyCopyAttributes(secKey) as? [CFString: Any]
                let keyType = secKeyAttrs?[kSecAttrKeyType] as? String
                values[tag] = KeyRep(tag: tag, type: keyType ?? "Unknown")
            }
        }

        return values
    }
}

struct KeyManagement_Previews: PreviewProvider {
    static var previews: some View {
        KeyManagement()
    }
}
