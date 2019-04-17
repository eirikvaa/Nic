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
/// Methods like `expression`, `multiplication` and so forth matches an expression of the respective type
/// or anything of _higher_ precedense.
struct Parser {
    var currentIndex = 0
    let tokens: [Token]
    
    init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    let types: [String: NicType] = [
        "Number": .number,
        "String": .string,
        "Bool": .boolean
    ]
    
    mutating func parseTokens() -> [Stmt] {
        var statements: [Stmt] = []
        
        while !isAtEnd() {
            // Only statements at top-level.
            if let declaration = try? declaration() {
                statements.append(declaration)
            }
        }
        
        return statements
    }
    
    mutating private func declaration() throws -> Stmt? {
        do {
            if match(types: .var) {
                return try variableDeclaration()
            }
            
            return try statement()
        } catch {
            // TODO: Synchronize
            return nil
        }
    }
    
    mutating func statement() throws -> Stmt? {
        if match(types: .print) {
            return try printStatement()
        }
        
        return nil
    }
    
    mutating private func printStatement() throws -> Stmt {
        // Advance beyond 'print' token
        advance()
        
        let printExpr = match(types: .semicolon) ? nil : try expression()
        let printStmt = Stmt.Print(value: printExpr)
        
        try consume(tokenType: .semicolon, errorMessage: "Expected semicolon.")
        
        return printStmt
    }
    
    mutating private func variableDeclaration() throws -> Stmt {
        let name = try consume(tokenType: .identifier, errorMessage: "Expect variable name.")
        
        var variableType: NicType?
        if match(types: .colon) {
            let type = try consume(tokenType: .identifier, errorMessage: "Expect a type after colon in variable declaration.")
            variableType = types[type.lexeme]
        }
        
        var initializer: Expr?
        if match(types: .equal) {
            initializer = try expression()
            
            // Don't let the type of the rvalue override a potential type annotation.
            if variableType == nil {
                variableType = initializer?.exprType()
            }
        }
        
        try consume(tokenType: .semicolon, errorMessage: "Expected ';' after variable declaration.")
        return Stmt.Var(name: name, type: variableType, initializer: initializer)
    }
    
    mutating private func expression() throws -> Expr {
        return try assignment()
    }
    
    mutating private func assignment() throws -> Expr {
        return try addition()
    }
    
    mutating private func addition() throws -> Expr {
        let expr = try multiplication()
        
        while match(types: .plus, .minus) {
            let op = previous()
            let right = try multiplication()
            return Expr.Binary(leftValue: expr, operator: op, rightValue: right)
        }
        
        return expr
    }
    
    mutating private func multiplication() throws -> Expr {
        let expr = try unary()
        
        while match(types: .star, .slash) {
            let op = previous()
            let right = try unary()
            return Expr.Binary(leftValue: expr, operator: op, rightValue: right)
        }
        
        return expr
    }
    
    mutating private func unary() throws -> Expr {
        if match(types: .minus) {
            let op = previous()
            let right = try unary()
            return Expr.Unary(operator: op, value: right)
        }
        
        return try primary()
    }
    
    mutating private func primary() throws -> Expr {
        if match(types: .number) {
            let expr = Expr.Literal(value: previous().literal)
            expr.type = .number
            return expr
        }
        
        if match(types: .string) {
            let expr = Expr.Literal(value: previous().literal)
            expr.type = .string
            return expr
        }
        
        if match(types: .true) {
            let expr = Expr.Literal(value: true)
            expr.type = .boolean
            return expr
        }
        
        if match(types: .false) {
            let expr = Expr.Literal(value: false)
            expr.type = .boolean
            return expr
        }
        
        if match(types: .identifier) {
            return Expr.Variable(name: previous())
        }
        
        throw NicParserError.missingRValue // TODO: Shold be "Expected expression or something"
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
        
        return peek().type == tokenType
    }
    
    // Returns the most recently consumed token
    private func previous(steps: Int = 1) -> Token {
        return tokens[currentIndex - steps]
    }
    
    // Returns the token we have _yet_ to consume
    private func peek() -> Token {
        return tokens[currentIndex]
    }
    
    private func isAtEnd() -> Bool {
        return tokens[currentIndex].type == .eof
    }
}
