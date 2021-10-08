//
//  NoKeysSection.swift
//  pgpt1
//
//  Created by Arthur Fayzrakhmanov on 08.09.2021.
//

import SwiftUI

struct NoKeysSection: View {
    @State var onGenerate: () -> Void = {}
    @Binding var buttonEnabled: Bool
    var body: some View {
        Section(header: Text("No keys")) {
            Button(action: onGenerate) {
                Text("Generate RSA key pair")
            }
            .disabled(!buttonEnabled)
        }
    }
}

struct NoKeysSection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            NoKeysSection(buttonEnabled: .constant(false))
        }
        .listStyle(InsetGroupedListStyle())
        .previewLayout(.sizeThatFits)
    }
}
