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
        print("Generating keys for \(usernameUnwrapped) \(String(decoding: tag, as: UTF8.self))")
        let attributes: [String: Any] =
        [kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
         kSecAttrKeySizeInBits as String: 2048,
         kSecPrivateKeyAttrs as String:
            [kSecAttrIsPermanent as String: true,
             kSecAttrApplicationTag as String: tag
            ]
        ]
        guard let privateKeyGenerated = SecKeyCreateRandomKey(attributes as CFDictionary, nil) else { return }
        print("Genrated key \(privateKeyGenerated)")
        onKeyGenerated(key: privateKeyGenerated)
        checkKeys()
    }

    private func deleteKey() {
        if (privateKey == nil || !usernameIsValid) {
            return
        }
        print("Deleting key \(userKeyAlias())")
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
        print("Checking key for \(usernameTrimmed())")
        let query: [String: Any] = userKeyQuery()
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { onKeyNotExists(); return }
        let key = item as! SecKey
        privateKey = key
    }

    private func onKeyNotExists() {
        print("Not exists")
        resetView()
    }

    private func resetView() {
        privateKey = nil
    }

    private func onKeyGenerated(key: SecKey) {
        checkKeys()
    }

    private func userKeyQuery(returnRef: Bool = true) -> [String: Any] {
        let tag = userKeyAlias().data(using: .utf8)!
        return [kSecClass as String: kSecClassKey,
                kSecAttrApplicationTag as String: tag,
                kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                kSecReturnRef as String: returnRef]

    }

    private func userKeyAlias() -> String {
        "com.example.keys.\(username ?? "no_user")_key"
    }

    private func usernameIsEmpty() -> Bool {
        usernameTrimmed().isEmpty
    }

    private func usernameTrimmed() -> String {
        guard let usernameUnwrapped = username else { return "" }
        return usernameUnwrapped.trimmingCharacters(in: .whitespaces)
    }
}

struct UserKeys_Previews: PreviewProvider {
    static var previews: some View {
        UserKeys(username: .constant("John Doe"), privateKey: .constant(nil))
    }
}
