//
//  Resolver.swift
//  Nic
//
//  Created by Eirik Vale Aase on 23/03/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

/// `Resolver` traverses the abstract syntax tree and resolves any global and local variables.
class Resolver {
    private var scopes: [[String: Bool]] = []
    private let codeGenerator: CodeGenerator
    private var scopeDepth = 0
    private let symbolTable = SymbolTable.shared
    
    init(codeGenerator: CodeGenerator) {
        self.codeGenerator = codeGenerator
    }
    
    func resolve(_ statements: [Stmt]) throws {
        for stmt in statements {
            try resolve(stmt)
        }
    }
}

extension Resolver: ExprVisitor {
    func visitAssignExpr(expr: Expr.Assign) throws {
        try resolve(expr.value)
        resolveLocal(expr: expr, name: expr.name)
    }
    
    func visitGroupExpr(expr: Expr.Group) throws {
        try resolve(expr.value)
    }
    
    func visitUnaryExpr(expr: Expr.Unary) throws {
        try resolve(expr.value)
    }
    
    func visitLiteralExpr(expr: Expr.Literal) throws {}
    
    func visitBinaryExpr(expr: Expr.Binary) throws {
        try resolve(expr.leftValue)
        try resolve(expr.rightValue)
    }
    
    func visitVariableExpr(expr: Expr.Variable) throws {
        guard let name = expr.name else {
            return
        }
        
        if !scopes.isEmpty, scopes[scopes.endIndex - 1][name.lexeme] == false {
            NicError.error(name.line, message: "Variable '\(name.lexeme)' used inside its own initializer.")
        }
        
        resolveLocal(expr: expr, name: name)
        
    }
}

extension Resolver: StmtVisitor {
    func visitExpressionStatement(_ stmt: Stmt.Expression) throws {
        try resolve(stmt.expression)
    }
    
    func visitConstStmt(_ stmt: Stmt.Const) throws {
        declare(stmt.name, mutable: false)
        
        try resolve(stmt.initializer)
        
        define(stmt.name)
    }
    
    func visitBlockStmt(_ stmt: Stmt.Block) throws {
        beginScope()
        try resolve(stmt.statements)
        endScope()
    }
    
    func visitVarStmt(_ stmt: Stmt.Var) throws {
        declare(stmt.name, mutable: true)
        
        if let initializer = stmt.initializer {
            try resolve(initializer)
        }
        
        symbolTable.set(element: true, at: \.isMutable, to: stmt.name, at: scopeDepth)
        
        define(stmt.name)
    }
    
    func visitPrintStmt(_ stmt: Stmt.Print) throws {
        if let value = stmt.value {
            try resolve(value)
        }
    }
}

private extension Resolver {
    func resolve(_ stmt: Stmt) throws {
        try stmt.accept(visitor: self)
    }
    
    func resolve(_ expr: Expr) throws {
        try expr.accept(visitor: self)
    }
    
    func resolveLocal(expr: Expr, name: Token) {
        expr.depth = scopeDepth
    }
    
    func declare(_ name: Token, mutable: Bool) {
        if scopes.isEmpty {
            return
        }
        
        let scope = scopes.endIndex - 1
        
        if scopes[scope].keys.contains(name.lexeme) == true {
            Nic.error(at: name.line, message: "Variable with this name is already declared in this scope.")
        }
        
        scopes[scope][name.lexeme] = false
    }
    
    func define(_ name: Token) {
        if scopes.isEmpty {
            return
        }
        
        scopes[scopes.endIndex - 1][name.lexeme] = true
    }
    
    func beginScope() {
        scopes.append([:])
        scopeDepth += 1
    }
    
    func endScope() {
        _ = scopes.popLast()
        scopeDepth -= 1
    }
}
