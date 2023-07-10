//
//  TokenType.swift
//  Nic
//
//  Created by Eirik Vale Aase on 10/03/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

// TODO: Create a namespace for the different token types, like one for mathematical operators?
enum TokenType: String {
    // literals
    case string
    case integer
    case double
    case `true`
    case `false`

    // operators
    case equal = "="
    case greater = ">"
    case less = "<"
    case greater_equal
    case less_equal
    case bang_equal
    case equal_equal
    case plus = "+"
    case minus = "-"
    case slash = "/"
    case star = "*"
    case bang = "!"

    // keywords
    case `var`
    case const
    case print
    case ifBranch = "if"
    case elseBranch = "else"
    case or
    case and

    // punctuation
    case semicolon = ";"
    case colon = ":"
    case leftParen = "("
    case rightParen = ")"
    case leftBrace = "{"
    case rightBrace = "}"

    // other
    case identifier
    case eof = "EOF"
}

extension TokenType {
    var isComparison: Bool {
        let comparison: [TokenType] = [.less, .greater, .less_equal, .greater_equal, .equal_equal, .bang_equal]
        return comparison.contains(self)
    }

    var isLogical: Bool {
        return self == .and || self == .or
    }
}
