//
//  Token.swift
//  Nic
//
//  Created by Eirik Vale Aase on 30.05.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation

enum TokenType {
    case string(characters: String)
    case number(value: Int)
    case `operator`(operator: String)
    case eof
}

struct Token {
    var type: TokenType
    var lexeme: String
}

extension Token: Equatable {
    static func ==(lhs: Token, rhs: Token) -> Bool {
        switch (lhs.type, rhs.type) {
        case (.string(let leftChars), .string(let rightChars)):
            return leftChars == rightChars
        case (.number(let leftNum), .number(let rightNum)):
            return leftNum == rightNum
        case (.operator(let opA), .operator(let opB)):
            return opA == opB
        case (.eof, .eof):
            return true
        default:
            return false
        }
    }
}

extension Token: CustomStringConvertible {
    var description: String {
        switch type {
        case .string(let characters):
            return "String[\"\(characters)\"]"
        case .number(let value):
            return "Number[\(value)]"
        case .operator(let `operator`):
            return "Operator[\(`operator`)]"
        case .eof:
            return "EOF"
        }
    }
}
