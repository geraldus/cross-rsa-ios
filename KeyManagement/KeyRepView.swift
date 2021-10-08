//
//  KeyRepView.swift
//  pgpt1
//
//  Created by Arthur Fayzrakhmanov on 15.09.2021.
//

import SwiftUI

func keyTypeText(keyType: String)->String {
    if keyType == (kSecAttrKeyTypeRSA as String){
        return "RSA"
    }
    else { return "Unknown" }
}

struct KeyRepView: View {
    @Binding var key: KeyRep
    var body: some View {
        HStack {
            Text("\(keyTypeText(keyType: key.type))")
            Text(key.tag)
        }
    }
}

struct KeyRepView_Previews: PreviewProvider {
    static var previews: some View {
        KeyRepView(key: .constant(KeyRep(tag: "Private Key", type: "RSAPrivateKey")))
    }
}
