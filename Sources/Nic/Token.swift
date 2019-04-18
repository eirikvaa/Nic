//
//  Token.swift
//  Nic
//
//  Created by Eirik Vale Aase on 30.05.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

struct Token {
    let type: TokenType
    let lexeme: String
    let literal: Any?
    let line: Int
}

extension Token: Equatable {
    static func ==(lhs: Token, rhs: Token) -> Bool {
        switch (lhs.type, rhs.type) {
        case (.string, .string):
            return lhs.literal as? String == rhs.literal as? String
        case (.integer, .integer):
            return lhs.literal as? Int == rhs.literal as? Int
        case (.double, .double):
            return lhs.literal as? Double == rhs.literal as? Double
        default:
            return lhs.lexeme == rhs.lexeme
        }
    }
}

extension Token: CustomStringConvertible {
    var description: String {
        return self.type.rawValue.uppercased()
    }
}
