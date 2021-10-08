//
//  KeyRep.swift
//  pgpt1
//
//  Created by Arthur Fayzrakhmanov on 15.09.2021.
//

import SwiftUI

struct KeyRepView: View {
    @Binding var key: KeyRep
    var body: some View {
        HStack {
            Text(key.tag)
            Text("\(key.type)")
        }
    }
}

struct KeyRepView_Previews: PreviewProvider {
    static var previews: some View {
        KeyRepView(key: .constant(KeyRep(tag: "Private Key", type: "RSAPrivateKey")))
    }
}
