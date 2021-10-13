//
//  DecryptMessage.swift
//  pgpt1
//
//  Created by Arthur Fayzrakhmanov on 09.10.2021.
//

import SwiftUI

struct DecryptMessage: View {
    @State var recipient: String = ""
    @State var encrypted: String = ""
    @State var decoded: String = ""
    @State var privateKey: SecKey? = nil
    @State var validKey: Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            List {
                Section(header: Text("Recipient")) {
                    TextField("Recipient name", text: $recipient).onChange(of: recipient) { newValue in
                        _ = checkValidity()
                        return
                    }

                    //                    if !inputKey.isEmpty {
                    //                        if (keyIsValid()) {
                    //                            Text("Key is supported")
                    //                                .font(.caption)
                    //                                .foregroundColor(Color.green)
                    //                        } else {
                    //                            Text("Key unpupported")
                    //                                .font(.caption)
                    //                                .foregroundColor(Color.red)
                    //                        }
                    //                    }
                }

                Section(header: Text("Encrypted message")) {
                    TextEditor(text: $encrypted)
                }

                Button(action: decode) {
                    Text("Decode")
                }
                .disabled(!validKey)

                Section(header: Text("Output (Decrypted Message)")) {
                    TextEditor(text: $decoded)
                }
            }
        }
    }

    private func decode() {
        let query: [String: Any] = userPrivateKeyQuery(atag: userKeyAlias(username: recipient), returnRef: true)
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { onKeyNotExists(); return }
        let key = item as! SecKey
        privateKey = key
        guard !encrypted.isEmpty
        else {
            print("Wrong ecrypted message")
            return
        }
        guard let data = encrypted.trimmingCharacters(in: .whitespacesAndNewlines).data(using: .utf8) else {
            print("Encrypted data bytes is null")
            return
        }
        print("MESSAGE: \(encrypted), size \(data.count)")
        guard let encodedData = Data(base64Encoded: data, options: .ignoreUnknownCharacters) else {
                print("Error reading encoded message bytes")
                return
            }
        guard let decodedText = rsaDecode(withKey: key, message: encodedData) else {
            print("Decoding error")
            return
        }
        decoded = String(decoding:decodedText, as: UTF8.self)
    }

    private func checkValidity() -> Bool {
        if recipient.isEmpty {
            reset()
            return false
        } else {
            let query: [String: Any] = userPrivateKeyQuery(atag: "com.example.keys.\(recipient)_key", returnRef: true)
            var item: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &item)
            guard status == errSecSuccess else {
                reset()
                return false
            }
            let key = item as! SecKey
            privateKey = key
            validKey = true
            return true
        }
    }

    private func onKeyNotExists() {
        
    }

    private func reset() {
        validKey = false
        privateKey = nil
    }
}

struct DecryptMessage_Previews: PreviewProvider {
    static var previews: some View {
        DecryptMessage()
    }
}
