//
//  ContentView.swift
//  pgpt1
//
//  Created by Arthur Fayzrakhmanov on 26.08.2021.
//

import SwiftUI

struct ContentView: View {
    @State var username: String? = nil
    @State var key: SecKey? = nil
    var body: some View {
        NavigationView {
            VStack {
                if let username = self.username  {
                    Text("\(username)")
                }
                Spacer()
                NavigationLink(
                    destination: UserKeys(username: $username, privateKey: $key),
                    label: {
                        Text("User Settings")
                    })
                Spacer()
                NavigationLink(
                    destination: EncryptMessage(),
                    label: {
                        Text("RSA: Encrypt Message")
                    })

                if let _ = key, let _ = username {
                    Spacer()
                    NavigationLink(destination: RsaEncryption(user: $username ?? "", key: Binding($key)!), label: {
                        Text("RSA Encryption")
                    })
                }

                Spacer()
                NavigationLink(
                    destination: KeyManagement(),
                    label: {
                        Text("Key Management")
                    })
                Spacer()
            }.onAppear() {
                print(kSecAttrKeyTypeRSA)
                print(kSecAttrKeyTypeRSA as String)
            }
        }
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
