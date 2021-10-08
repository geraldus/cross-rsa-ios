//
//  KeysView.swift
//  pgpt1
//
//  Created by Arthur Fayzrakhmanov on 08.09.2021.
//

import SwiftUI

struct KeysView: View {
    @State var publicKey: String = ""
    @State var privateKey: String = ""
    var onGenerateNewKeys: () -> Void = {}
    var body: some View {
        Section(header: Text("Known keys")) {
            VStack(alignment: .leading) {
                Text("Publick Key")
                Text("\(publicKey)")
                    .font(.caption)
                Divider()
                Text("Private Key")
                Text("\(privateKey)")
                    .font(.caption)
            }
            Button(action: onGenerateNewKeys, label: {
                Text("Generate New Keys")
            })
        }
    }
}

struct KeysView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            KeysView(publicKey: "MIIBCgKCAQEAn6RvMy0nt5ulbDuz+Rb/UTAI+Ke0e2pPg6gA26PbHcA5ovDMO242kIe635vt8Kk6IeAdSbS9yHu7aP1iSgnDpMbYNaHGQ4aw73CqbzEP9aw+xAfscz54DoMFtod74mX7hcDeGr+QVigGBf61t93IaUjmGpofj6/CKGZ8WUsjb4Wg/8yiMFY70vU33qe67w6T1UObIdVlV9POS2z7g/5qtscRs3B0UJNkrMt5zOG0vY7BJjICcOKQFHpZhCSe9QbR0ryr+oprwJlGdm4jaaqRbUTz94sck0mZS82GnODGaiOXY1VuOOYBOVXpSWcMpFFZrTzc8mx9gscWaqCrwVyNDwIDAQAB", privateKey: "0x6000035056c0")
        }
        .listStyle(InsetGroupedListStyle())
        .previewLayout(.sizeThatFits)
    }
}
