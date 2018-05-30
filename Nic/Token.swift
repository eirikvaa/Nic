//
//  Token.swift
//  Nic
//
//  Created by Eirik Vale Aase on 30.05.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation

enum TokenType: String {
    case number
    case `operator`
}

extension TokenType: CustomStringConvertible {
    var description: String {
        return rawValue.capitalized
    }
}

struct Token {
    var type: TokenType
    var lexeme: String
    var value: Any?
}

extension Token: CustomStringConvertible {
    var description: String {
        return type.description
    }
}
