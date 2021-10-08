//
//  EncryptMessage.swift
//  pgpt1
//
//  Created by Arthur Fayzrakhmanov on 08.10.2021.
//

import SwiftUI

struct EncryptMessage: View {
    @State var inputKey: String = ""
    @State var encrypted: String = ""
    @State var message: String = "TOP SECRET"
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            List {
                Section(header: Text("Recipient public key")) {
                    TextEditor(text: $inputKey)

                    if !inputKey.isEmpty {
                        if (keyIsValid()) {
                            Text("Key is supported")
                                .font(.caption)
                                .foregroundColor(Color.green)
                        } else {
                            Text("Key unpupported")
                                .font(.caption)
                                .foregroundColor(Color.red)
                        }
                    }

                    Section(header: Text("Message")) {
                        TextEditor(text: $message)
                    }

                    Button(action: encode) {
                        Text("Encode")
                    }
                    .disabled(!correctKeyLength())
                }

                Section(header: Text("Output (Encoded Message)")) {
                    TextEditor(text: $encrypted)
                }
            }
        }

    }

    private func encode() {
        guard correctKeyLength() else {
            return
        }
        guard let key = buildKey(), keyIsValid() else {
            return
        }
        guard !message.isEmpty else {
            print("Error: empty message")
            return
        }
        guard let ciperTextData = rsaEncode(withKey: key, message: message)
        else {
            print("Encoding error")
            return
        }
        encrypted = ciperTextData.base64EncodedString()
    }

    private func correctKeyLength() -> Bool {
        // TODO: Decode ekey to bytes (base64) and calculate key size
        // in bytes, check that it have proper size.
        // Checks non-null content for now.
        return !inputKey.isEmpty
    }

    private func buildKey() -> SecKey? {
        pubKey(from: inputKey, rsaPubKeyAttrs)
    }

    private func keyIsValid() -> Bool {
        guard let key = buildKey() else {
            return false
        }

        return SecKeyIsAlgorithmSupported(key, .encrypt, .rsaEncryptionOAEPSHA256)
    }
}

struct EncryptMessage_Previews: PreviewProvider {
    static var previews: some View {
        EncryptMessage()
    }
}
