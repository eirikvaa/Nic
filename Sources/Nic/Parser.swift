//
//  Parser.swift
//  Nic
//
//  Created by Eirik Vale Aase on 10/03/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

/// The parser will make sure that the list of tokens created during the lexical analysis will adhere to the
/// correct syntax of the language, or report syntax errors.
/// Methods like `expression`, `multiplication` and so forth matches an expression of the respective type
/// or anything of _higher_ precedense.
struct Parser {
    private var currentIndex = 0
    private let tokens: [Token]
    private let symbolTable = SymbolTable.shared
    private var scopeDepth = 0
    
    init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    private let types: [String: NicType] = [
        "Int": .integer,
        "Double": .double,
        "String": .string,
        "Bool": .boolean
    ]
    
    mutating func parse() -> [Stmt] {
        var statements: [Stmt] = []
        
        while !isAtEnd() {
            // Only statements at top-level.
            if let declaration = try? declaration() {
                statements.append(declaration)
            }
        }
        
        return statements
    }
}

private extension Parser {
    mutating func declaration() throws -> Stmt? {
        do {
            if match(types: .var) {
                return try variableDeclaration()
            } else if match(types: .const) {
                return try constDeclaration()
            }
            
            return try statement()
        } catch {
            synchronize()
            return nil
        }
    }
    
    mutating func statement() throws -> Stmt? {
        
        if match(types: .print) {
            return try printStatement()
        } else if match(types: .leftBrace) {
            return try block()
        }
        
        return try expressionStatement()
    }
    
    mutating func printStatement() throws -> Stmt {
        var value: Expr?
        if match(types: .semicolon) {
            value = nil
        } else {
            value = try expression()
            try consume(tokenType: .semicolon, errorMessage: "Expected semicolon after print statement.")
        }
        
        let printStmt = Stmt.Print(value: value)
        
        return printStmt
    }
    
    mutating func block() throws -> Stmt {
        symbolTable.beginScope()
        scopeDepth += 1
        
        var statements: [Stmt] = []
        
        while (!check(tokenType: .rightBrace) && !isAtEnd()) {
            if let declaration = try? declaration() {
                statements.append(declaration)
            }
        }
        
        try consume(tokenType: .rightBrace, errorMessage: "Expecting right brace to complete block.")
        
        scopeDepth -= 1
        
        return Stmt.Block(statements: statements)
    }
    
    mutating func expressionStatement() throws -> Stmt {
        let expr = try expression()
        expr.depth = scopeDepth
        try consume(tokenType: .semicolon, errorMessage: "Expected ';' after expression statement.")
        return Stmt.Expression(expression: expr)
    }
    
    mutating func variableDeclaration() throws -> Stmt {
        let name = try consume(tokenType: .identifier, errorMessage: "Expect name for variable.")
        
        var variableType: NicType?
        if match(types: .colon) {
            let type = try consume(tokenType: .identifier, errorMessage: "Expect a type after colon in variable declaration.")
            variableType = types[type.lexeme]
        }
        
        var initializer: Expr?
        if match(types: .equal) {
            initializer = try expression()
            initializer?.depth = scopeDepth
        }
        
        let depth = initializer?.depth ?? 0
        symbolTable.set(element: nil, at: \.value, to: name, at: depth)
        symbolTable.set(element: true, at: \.isMutable, to: name, at: depth)
        
        try consume(tokenType: .semicolon, errorMessage: "Expected ';' after variable declaration.")
        return Stmt.Var(name: name, type: variableType, initializer: initializer)
    }
    
    mutating func constDeclaration() throws -> Stmt {
        let name = try consume(tokenType: .identifier, errorMessage: "Expect name for constant.")
        
        var constantType: NicType?
        if match(types: .colon) {
            let type = try consume(tokenType: .identifier, errorMessage: "Expect a type after colon in constant declaration.")
            constantType = types[type.lexeme]
        }
        
        try consume(tokenType: .equal, errorMessage: "Expect initializer for constant declaration.")
        let initializer = try expression()
        initializer.depth = scopeDepth
        
        symbolTable.set(element: nil, at: \.value, to: name, at: initializer.depth)
        symbolTable.set(element: false, at: \.isMutable, to: name, at: initializer.depth)
        
        try consume(tokenType: .semicolon, errorMessage: "Expected ';' in constant declaration.")
        return Stmt.Const(name: name, type: constantType, initializer: initializer)
    }
    
    mutating func expression() throws -> Expr {
        return try assignment()
    }
    
    mutating func assignment() throws -> Expr {
        let expr = try addition()
        
        if match(types: .equal) {
            let equals = previous()
            let value = try assignment()
            
            if let variable = expr as? Expr.Variable,
                let name = variable.name {
                let assign = Expr.Assign(name: name, value: value)
                assign.depth = scopeDepth
                return assign
            }
            
            Nic.error(at: equals.line, message: "Invalid assignment target!")
        }
        
        return expr
    }
    
    mutating func addition() throws -> Expr {
        var expr = try multiplication()
        
        while match(types: .plus, .minus) {
            let op = previous()
            let right = try multiplication()
            expr = Expr.Binary(leftValue: expr, operator: op, rightValue: right)
            expr.depth = scopeDepth
        }
        
        return expr
    }
    
    mutating func multiplication() throws -> Expr {
        var expr = try unary()
        
        while match(types: .star, .slash) {
            let op = previous()
            let right = try unary()
            expr = Expr.Binary(leftValue: expr, operator: op, rightValue: right)
            expr.depth = scopeDepth
        }
        
        return expr
    }
    
    mutating func unary() throws -> Expr {
        if match(types: .minus) {
            let op = previous()
            let right = try unary()
            let unary = Expr.Unary(operator: op, value: right)
            unary.depth = scopeDepth
            return unary
        }
        
        return try primary()
    }
    
    mutating func primary() throws -> Expr {
        if match(types: .integer) {
            let expr = Expr.Literal(value: previous().literal)
            expr.type = .integer
            expr.depth = scopeDepth
            return expr
        }
        
        if match(types: .double) {
            let expr = Expr.Literal(value: previous().literal)
            expr.type = .double
            expr.depth = scopeDepth
            return expr
        }
        
        if match(types: .string) {
            let expr = Expr.Literal(value: previous().literal)
            expr.type = .string
            expr.depth = scopeDepth
            return expr
        }
        
        if match(types: .true) {
            let expr = Expr.Literal(value: true)
            expr.type = .boolean
            expr.depth = scopeDepth
            return expr
        }
        
        if match(types: .false) {
            let expr = Expr.Literal(value: false)
            expr.type = .boolean
            expr.depth = scopeDepth
            return expr
        }
        
        if match(types: .identifier) {
            let variable = Expr.Variable(name: previous())
            variable.depth = scopeDepth
            return variable
        }
        
        if match(types: .leftParen) {
            let expr = try expression()
            
            try consume(tokenType: .rightParen, errorMessage: "Expecting ')' in parenthesized expression.")
            
            let group = Expr.Group(value: expr)
            group.depth = scopeDepth
            
            return group
        }
        
        throw NicError.missingRightValue // TODO: Shold be "Expected expression or something"
    }
    
    @discardableResult
    mutating func consume(tokenType: TokenType, errorMessage: String) throws -> Token {
        guard check(tokenType: tokenType) else {
            Nic.error(at: previous().line, message: errorMessage)
            throw NicError.unexpectedToken(token: peek())
        }
        
        return advance()
    }
    
    mutating func synchronize() {
        advance()
        
        while (!isAtEnd()) {
            if previous().type == .semicolon {
                return
            }
            
            switch peek().type {
            case .var,
                 .print:
                return
            default:
                break
            }
            
            advance()
        }
    }
    
    @discardableResult
    mutating func advance(steps: Int = 1) -> Token {
        if !isAtEnd() {
            currentIndex += steps
        }
        return tokens[currentIndex - steps]
    }
    
    mutating func match(types: TokenType...) -> Bool {
        for type in types {
            if check(tokenType: type) {
                advance()
                return true
            }
        }
        
        return false
    }
    
    func check(tokenType: TokenType) -> Bool {
        guard isAtEnd() == false else {
            return false
        }
        
        return peek().type == tokenType
    }
    
    // Returns the most recently consumed token
    func previous(steps: Int = 1) -> Token {
        return tokens[currentIndex - steps]
    }
    
    // Returns the token we have _yet_ to consume
    func peek() -> Token {
        return tokens[currentIndex]
    }
    
    func isAtEnd() -> Bool {
        return tokens[currentIndex].type == .eof
    }
}
