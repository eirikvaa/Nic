//
//  Resolver.swift
//  Nic
//
//  Created by Eirik Vale Aase on 23/03/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

/// `Resolver` traverses the abstract syntax tree and resolves any global and local variables.
class Resolver {
    var scopes: [[String: Bool]] = []
    let irGenerator: IRGenerator
    
    init(irGenerator: IRGenerator) {
        self.irGenerator = irGenerator
    }
}

extension Resolver: ExprVisitor {
    func visitUnaryExpr(expr: Expr.Unary) throws -> () {
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
    func visitBlockStmt(_ stmt: Stmt.Block) throws -> () {
        beginScope()
        try resolve(stmt.statements)
        endScope()
    }
    
    func visitVarStmt(_ stmt: Stmt.Var) throws {
        declare(stmt.name)
        
        if let initializer = stmt.initializer {
            try resolve(initializer)
        }
        
        define(stmt.name)
    }
    
    func visitPrintStmt(_ stmt: Stmt.Print) throws {
        if let value = stmt.value {
            try resolve(value)
        }
    }
}

extension Resolver {
    func resolve(_ statements: [Stmt]) throws {
        for stmt in statements {
            try resolve(stmt)
        }
    }
    
    func resolve(_ stmt: Stmt) throws {
        try stmt.accept(visitor: self)
    }
    
    func resolve(_ expr: Expr) throws {
        try expr.accept(visitor: self)
    }
    
    func resolveLocal(expr: Expr, name: Token) {
        for i in stride(from: scopes.count - 1, through: 0, by: -1) {
            if scopes[i].keys.contains(name.lexeme) {
                irGenerator.resolve(expr: expr, depth: scopes.count - i - 1)
                return
            }
        }
        
        // Not found. Assume it is global.
    }
    
    func declare(_ name: Token) {
        if scopes.isEmpty {
            return
        }
        
        if scopes[scopes.endIndex - 1].keys.contains(name.lexeme) == true {
            Nic.error(at: name.line, message: "Variable with this name is already declared in this scope.")
        }
        
        scopes[scopes.endIndex - 1][name.lexeme] = false
    }
    
    func define(_ name: Token) {
        if scopes.isEmpty {
            return
        }
        
        scopes[scopes.endIndex - 1][name.lexeme] = true
    }
    
    func beginScope() {
        scopes.append([:])
    }
    
    func endScope() {
        _ = scopes.popLast()
    }
}
