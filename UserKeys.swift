//
//  KeyManagement.swift
//  pgpt1
//
//  Created by Arthur Fayzrakhmanov on 03.09.2021.
//

import SwiftUI


func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}

struct UserKeys: View {
    @Binding var username: String?
    @Binding var privateKey: SecKey?
    @State private var usernameIsValid: Bool = false
    var body: some View {
        List {
            TextField("Username", text: $username ?? "")
                .onChange(of: username, perform: { _ in
                    checkKeys()
                })

            if privateKey == nil {
                NoKeysSection(onGenerate: generateKeys, buttonEnabled: $usernameIsValid)
            } else {
                let publicKey = SecKeyCopyPublicKey(privateKey!)
                let algorithm: SecKeyAlgorithm = .rsaEncryptionOAEPSHA256
                let isSupported = publicKey == nil
                ? false
                : SecKeyIsAlgorithmSupported(publicKey!, .encrypt, algorithm)
                let pub = getPublicKeyString(key: privateKey!)
                if (pub == nil) {
                    NoKeysSection(onGenerate: generateKeys, buttonEnabled: $usernameIsValid)
                } else {
                    KeysView(publicKey: pub!, privateKey: "RSA KEY STORED IN KEYCHAIN", isSupported: isSupported, onGenerateNewKeys: generateKeys, onDeleteKey: deleteKey)
                }
                
            }
        }
        .listStyle(InsetGroupedListStyle())
        .onAppear(perform: checkKeys)
    }

    /// Generate new RSA key pair for currently user
    private func generateKeys() {
        let username = username?.trimmingCharacters(in: .whitespaces)
        guard let usernameUnwrapped = username else { return; }
        guard !usernameUnwrapped.isEmpty else { return; }
        let tag = userKeyAlias().data(using: .utf8)!
        if (privateKey != nil) {
            deleteKey()
        }
        let attributes: [String: Any] =
        [kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
         kSecAttrKeySizeInBits as String: 2048,
         kSecPrivateKeyAttrs as String:
            [kSecAttrIsPermanent as String: true,
             kSecAttrApplicationTag as String: tag
            ]
        ]
        guard let privateKeyGenerated = SecKeyCreateRandomKey(attributes as CFDictionary, nil) else { return }
        onKeyGenerated(key: privateKeyGenerated)
        checkKeys()
    }

    private func deleteKey() {
        if (privateKey == nil || !usernameIsValid) {
            return
        }
        let query: [String: Any] = userKeyQuery()
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else { onKeyNotExists(); return }
        checkKeys()
    }

    /// Check if any keys are present for typed username
    private func checkKeys() {
        guard !(usernameIsEmpty()) else {
            usernameIsValid = false;
            resetView()
            return
        }
        usernameIsValid = true
        let query: [String: Any] = userKeyQuery()
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { onKeyNotExists(); return }
        let key = item as! SecKey
        privateKey = key
    }

    private func onKeyNotExists() {
        resetView()
    }

    private func resetView() {
        privateKey = nil
    }

    private func onKeyGenerated(key: SecKey) {
        checkKeys()
    }

    private func userKeyQuery(returnRef: Bool = true) -> [String: Any] {
        userPrivateKeyQuery(atag: userKeyAlias(), returnRef: returnRef)
    }

    private func userKeyAlias() -> String {
        pgpt1.userKeyAlias(username: username)
    }

    private func usernameIsEmpty() -> Bool {
        guard let username = username else { return false }
        return pgpt1.usernameIsEmpty(username: username)
    }

    private func usernameTrimmed() -> String {
        pgpt1.usernameTrimmed(username: username)
    }
}

struct UserKeys_Previews: PreviewProvider {
    static var previews: some View {
        UserKeys(username: .constant("John Doe"), privateKey: .constant(nil))
    }
}
