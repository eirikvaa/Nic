//
//  Character+Ext.swift
//  Nic
//
//  Created by Eirik Vale Aase on 18/04/2019.
//

extension Character {
    var isAlphaNumeric: Bool {
        return isLetter || isNumber
    }
}
