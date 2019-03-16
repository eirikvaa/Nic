//
//  Parser.swift
//  Nic
//
//  Created by Eirik Vale Aase on 10/03/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

import Foundation

/// The parser will make sure that the list of tokens created during the lexical analysis will adhere to the
/// correct syntax of the language, or report syntax errors.
struct Parser {
    var currentIndex = 0
    let tokens: [Token]
    
    init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    mutating func parseTokens() throws {
        let startToken = advance()
        
        while !isAtEnd() {
            try parseToken(startToken)
        }
    }
    
    mutating private func parseToken(_ token: Token) throws {
        switch token.type {
        case .var: try variableDeclaration()
        default: throw NicParserError.unexpectedToken(token: token)
        }
    }
    
    mutating private func variableDeclaration() throws {
        try consume(tokenType: .var, errorMessage: "A variable declaration must start with the var keyword.")
        try consume(tokenType: .identifier, errorMessage: "A variable declaration needs an identifier.")
        try consume(tokenType: .equal, errorMessage: "Must bind an identifier to a value with an equals sign.")
        try value()
        try consume(tokenType: .semicolon, errorMessage: "Statement must be terminated with a semicolon.")
    }
    
    mutating private func value() throws {
        switch previous().type {
            case .string,
                 .number:
            advance()
        default:
            throw NicParserError.illegalRightValue
        }
    }
    
    mutating private func consume(tokenType: TokenType, errorMessage: String) throws {
        guard previous().type == tokenType else {
            print(errorMessage)
            throw NicParserError.unexpectedToken(token: previous())
        }
        
        advance()
    }
    
    @discardableResult
    mutating private func advance(steps: Int = 1) -> Token {
        currentIndex += steps
        return tokens[currentIndex - steps]
    }
    
    private func previous() -> Token {
        return tokens[currentIndex - 1]
    }
    
    private func isAtEnd() -> Bool {
        return currentIndex >= tokens.count
    }
}
