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
    case eof
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

extension Token: Equatable {
    static func ==(lhs: Token, rhs: Token) -> Bool {
        return lhs.type == rhs.type
    }
}

extension Token: CustomStringConvertible {
    var description: String {
        switch (type, value) {
        case (_, let number as Int):
            return "\(type)(\(number)))"
        case (_, let `operator` as String):
            return "\(type)\(`operator`)"
        case (.eof, _):
            return "EOF"
        default:
            return "\(type)\(String(describing: value))"
        }
    }
}
