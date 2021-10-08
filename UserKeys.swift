//
//  KeyManagement.swift
//  pgpt1
//
//  Created by Arthur Fayzrakhmanov on 03.09.2021.
//

import SwiftUI

struct KeyManagement: View {
    @State private var username: String = ""
    @State private var publicKey: String? = nil
    @State private var privateKey: String? = nil
    @State private var usernameIsValid: Bool = false
    var body: some View {
        List {
            TextField("Username", text: $username)
                .onChange(of: username, perform: { value in
                    checkKeys()
                })
            if let publicKey = publicKey, let privateKey = privateKey {
                KeysView(publicKey: publicKey, privateKey: privateKey, onGenerateNewKeys: generateKeys)
            } else {
                NoKeysSection(onGenerate: generateKeys, buttonEnabled: $usernameIsValid)
            }
        }
        .listStyle(InsetGroupedListStyle())
    }

    /// Generate new RSA key pair for currently user
    private func generateKeys() {
        print("Generating new RSA keys for \(username)")
        let username = username.trimmingCharacters(in: .whitespaces)
        guard !username.isEmpty else { return; }
        print("Generating keys for \(username)")
        let tag = userKeyAlias().data(using: .utf8)!
        let attributes: [String: Any] =
            [kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
             kSecAttrKeySizeInBits as String: 2048,
             kSecPrivateKeyAttrs as String:
                [kSecAttrIsPermanent as String: true,
                 kSecAttrApplicationTag as String: tag]
            ]
        let query: [String: Any] = [kSecClass as String: kSecClassKey,
                                    kSecAttrApplicationTag as String: tag,
                                    kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                                    kSecReturnRef as String: false]
        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if updateStatus == errSecItemNotFound {
            guard let privateKeyGenerated = SecKeyCreateRandomKey(attributes as CFDictionary, nil) else { return }
            print("Genrated key \(privateKeyGenerated)")
            onKeyGenerated(key: privateKeyGenerated)
        } else {
            let x = SecCopyErrorMessageString(updateStatus, nil)
            print("Update status \(String(describing: x))")
            checkKeys()
        }
    }

    /// Check if any keys are present for typed username
    private func checkKeys() {
        let usernameTrimmed = username.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard !(usernameTrimmed.isEmpty) else { usernameIsValid = false; return }
        usernameIsValid = true
        print("Checking key for \(usernameTrimmed)")
        let tag = userKeyAlias().data(using: .utf8)!
        let query: [String: Any] = [kSecClass as String: kSecClassKey,
                                    kSecAttrApplicationTag as String: tag,
                                    kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                                    kSecReturnRef as String: true]
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { onKeyNotExists(); return }
        let key = item as! SecKey
        let publicKeyCopy = SecKeyCopyPublicKey(key)!
        print("Key: \(key)")
        print("Pub:")
        print("\(publicKey ?? "no key")")
        do {
            var error: Unmanaged<CFError>?
            guard let secKeyExport = SecKeyCopyExternalRepresentation(publicKeyCopy, &error) else {
                throw error!.takeRetainedValue() as Error
            }
            let pubData = secKeyExport as Data?
            print("PUB -> \(pubData!.base64EncodedString())")
            publicKey = pubData!.base64EncodedString()
            privateKey = "RSA KEY STORED IN KEYCHAIN"
        } catch {
            print("ERROR")
        }
    }

    private func onKeyNotExists() {
        print("Not exists")
        privateKey = nil
        publicKey = nil
    }

    private func onKeyGenerated(key: SecKey) {
        checkKeys()
    }

    private func userKeyAlias() -> String {
        "com.example.keys.\(username)_key"
    }

    private func usernameIsEmpty() -> Bool {
        username.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

struct KeyManagement_Previews: PreviewProvider {
    static var previews: some View {
        KeyManagement()
    }
}
