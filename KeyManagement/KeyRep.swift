//
//  KeyRepType.swift
//  pgpt1
//
//  Created by Arthur Fayzrakhmanov on 15.09.2021.
//

import Foundation

class KeyRep {
    var tag: String
    var type: String

    init(copy k: KeyRep) {
        self.tag = k.tag
        self.type = k.type
    }

    init(tag: String, type: String) {
        self.tag = tag
        self.type = type
    }
}
