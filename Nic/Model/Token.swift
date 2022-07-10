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

    func debugString() -> String {
        return "\(line): \(lexeme) | \(type.rawValue) | \(literal ?? "")"
    }
}

extension Token: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(lexeme)

        switch literal {
        case let number as Int:
            hasher.combine(number)
        case let string as String:
            hasher.combine(string)
        case let double as Double:
            hasher.combine(double)
        case let bool as Bool:
            hasher.combine(bool)
        default:
            break
        }

        hasher.combine(line)
    }
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
        case (.true, .true),
             (.false, .false):
            return lhs.literal as? Bool == rhs.literal as? Bool
        default:
            return lhs.lexeme == rhs.lexeme
        }
    }
}

extension Token: CustomStringConvertible {
    var description: String {
        return literal == nil ? lexeme : type.rawValue.uppercased()
    }
}
