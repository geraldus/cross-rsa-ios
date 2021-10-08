//
//  RsaEncryption.swift
//  pgpt1
//
//  Created by Arthur Fayzrakhmanov on 30.09.2021.
//

import SwiftUI

struct RsaEncryption: View {
    @Binding var user: String
    @Binding var key: SecKey
    @State var message: String = ""
    @State var lastEncryptedMessage: String = ""
    @State var encryptionNotSupportedAlert: Bool = false
    @State var messageTooLongAlert: Bool = false
    @State var noPubKeyAlert: Bool = false
    @State var encryptionFailAlert: Bool = false
    var body: some View {
        VStack {
            HStack {
                Text("Message encryption for")
                Text(user)
                    .bold()
            }
            Spacer()
            List {
                TextField("Message to encrypt", text: $message)
                    .lineLimit(10)
                    .fixedSize()
                Button("Encrypt", action: {
                    encrypt()
                })
                    .alert(isPresented: $noPubKeyAlert) {
                        Alert(title: Text("Encryption error"), message: Text("No public key"), dismissButton: .cancel())
                    }
                    .alert(isPresented: $encryptionNotSupportedAlert) {
                        Alert(title: Text("Encryption error"), message: Text("Key is not supported for target encryption operation"), dismissButton: .cancel())
                    }
                    .alert(isPresented: $messageTooLongAlert) {
                        Alert(title: Text("Encryption error"), message: Text("Message too long"), dismissButton: .cancel())
                    }
                    .alert(isPresented: $encryptionFailAlert) {
                        Alert(title: Text("Encryption error"), message: Text("Operation failed"), dismissButton: .cancel())
                    }
                Section(header: Text("Key")) {
                    Text(getPublicKeyString(key: key) ?? "—")
                        .font(.caption)
                }
                Section(header: Text("Encrypted")) {
                    Text(lastEncryptedMessage.isEmpty ? "No message" : lastEncryptedMessage)
                }
            }
            Spacer()
        }
    }

    private func reset() {
        lastEncryptedMessage = ""
    }

    private func encrypt() {
        guard let publicKey = SecKeyCopyPublicKey(key) else {
            noPubKeyAlert = true
            reset()
            return
        }

        var error: Unmanaged<CFError>?

        let algorithm: SecKeyAlgorithm = .rsaEncryptionOAEPSHA256

        let attributes: [String: Any] = [kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                                         kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
                                         kSecAttrKeySizeInBits as String: 2048]

        //        let publicKeyString = getPublicKeyString(key: key)
        guard let publicKeyString = getPublicKeyString(key: key), let publicKeyRecons = pubKey(from: publicKeyString, attributes)
        else {
            reset()
            return
        }

        guard SecKeyIsAlgorithmSupported(publicKeyRecons, .encrypt, algorithm) else {
            encryptionNotSupportedAlert = true
            reset()
            return
        }


        guard messageSizeValid(withKey: publicKey, message: message) else {
            messageTooLongAlert = true
            reset()
            return
        }

        guard let cipherText = rsaEncode(withKey: publicKeyRecons, message: message) else {
            encryptionFailAlert = true
            return
        }

        guard let cipherText2 = rsaEncode(withKey: publicKey, message: message) else {
            return
        }
        print(">>> PURE <<<")
        print(cipherText2.base64EncodedString())

        lastEncryptedMessage = cipherText.base64EncodedString()
        print(">>> ENCODED MESSAGE <<<")
        print(lastEncryptedMessage)
        // String(decoding: cipherText, as: UTF8.self)
        guard let clearText = SecKeyCreateDecryptedData(key,
                                                        algorithm,
                                                        cipherText as CFData,
                                                        &error) as Data? else {
            return reset()
            //            throw error!.takeRetainedValue() as Error
        }
        guard let clearText2 = SecKeyCreateDecryptedData(key,
                                                         algorithm,
                                                         cipherText2 as CFData,
                                                         &error) as Data? else {
            return reset()
            //            throw error!.takeRetainedValue() as Error
        }
        print("CLEARED 1: \(String(decoding:clearText, as: UTF8.self))")
        print("CLEARED 2: \(String(decoding:clearText2, as: UTF8.self))")
    }
}

struct RsaEncryption_Previews: PreviewProvider {
    static var previews: some View {
        let attributes: [String: Any] =
        [kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
         kSecAttrKeySizeInBits as String: 2048,
         kSecPrivateKeyAttrs as String:
            [kSecAttrIsPermanent as String: false,
             kSecAttrApplicationTag as String: "preview"]
        ]
        if let key = SecKeyCreateRandomKey(attributes as CFDictionary, nil) {
            RsaEncryption(user: .constant("John Doe"), key: .constant(key))
        } else {
            Text("ERROR")
        }
    }
}
