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
    
    mutating func parseTokens() throws -> [Stmt] {
        var statements: [Stmt] = []
        
        while !isAtEnd() {
            // Only declarations can be found in the global level.
            // TODO: Should also allow expressions in the global level.
            if let declaration = declaration() {
                statements.append(declaration)
            }
        }
        
        return statements
    }
    
    mutating private func declaration() -> Stmt? {
        do {
            if match(types: .var) {
                return try variableDeclaration()
            }
            
            fatalError("Not supported declaration.")
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    mutating private func variableDeclaration() throws -> Stmt {
        let name = try consume(tokenType: .identifier, errorMessage: "Expect variable name.")
        
        var initializer: Expr?
        if match(types: .equal) {
            initializer = try expression()
        }
        
        try consume(tokenType: .semicolon, errorMessage: "Expected ';' after variable declaration.")
        return Stmt.Var(name: name, initializer: initializer)
    }
    
    mutating private func expression() throws -> Expr {
        return try addition()
    }
    
    mutating private func addition() throws -> Expr {
        let expr = try assignment()
        
        while match(types: .plus, .minus) {
            let `operator` = previous()
            let right = try primary()
            return Expr.Binary(leftValue: expr, operator: `operator`, rightValue: right)
        }
        
        return expr
    }
    
    mutating private func assignment() throws -> Expr {
        let expr = try primary()
        
        return expr
    }
    
    mutating private func primary() throws -> Expr {
        if match(types: .number, .string) {
            return Expr.Literal(value: previous().literal)
        }
        
        throw NicParserError.missingRValue // TODO: Shold be "Expected expression or something"
    }
    
    mutating private func value() throws {
        let _previous = previous()
        switch _previous.type {
            case .string,
                 .number:
            advance()
        case .semicolon:
            throw NicParserError.missingRValue
        default:
            throw NicParserError.illegalRightValue(token: _previous)
        }
    }
    
    @discardableResult
    mutating private func consume(tokenType: TokenType, errorMessage: String) throws -> Token {
        guard check(tokenType: tokenType) else {
            throw NicParserError.unexpectedToken(token: peek())
        }
        
        return advance()
    }
    
    @discardableResult
    mutating private func advance(steps: Int = 1) -> Token {
        currentIndex += steps
        return tokens[currentIndex - steps]
    }
    
    mutating private func match(types: TokenType...) -> Bool {
        for type in types {
            if check(tokenType: type) {
                advance()
                return true
            }
        }
        
        return false
    }
    
    private func check(tokenType: TokenType) -> Bool {
        guard isAtEnd() == false else {
            return false
        }
        
        return tokens[currentIndex].type == tokenType
    }
    
    private func previous(steps: Int = 1) -> Token {
        return tokens[currentIndex - steps]
    }
    
    private func peek() -> Token {
        return tokens[currentIndex]
    }
    
    private func isAtEnd() -> Bool {
        return tokens[currentIndex].type == .eof
    }
}
