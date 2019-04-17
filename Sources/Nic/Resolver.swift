//
//  Resolver.swift
//  Nic
//
//  Created by Eirik Vale Aase on 23/03/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

import Foundation

/// In the Visitor Pattern the `Resolver` acts as the visitor, because it implements all the `visit`
/// methods. The resolver will do a single pass over the tree and resolve any variables.
/// TODO: Identifiers must here be resolved. Use scopes.
class Resolver {
    var scopes: Stack<[String: Bool]> = []
}

extension Resolver: ExprVisitor {
    func visitLiteralExpr(expr: Expr.Literal) throws {}
    
    func visitBinaryExpr(expr: Expr.Binary) throws {
        try resolve(expr.leftValue)
        try resolve(expr.rightValue)
    }
    
    func visitVariableExpr(expr: Expr.Variable) throws {
        guard let name = expr.name else {
            return
        }
        
        guard let currentScope = scopes.peek() else {
            return
        }
        
        guard currentScope[name.lexeme] == true else {
            NicError.error(name.line, message: "Can't use a variable before it's initialized.")
            return // Maybe throw?
        }
        
        
    }
}

extension Resolver: StmtVisitor {
    func visitVarStmt(_ stmt: Stmt.Var) throws {
        define(stmt.name)
        
        if let initializer = stmt.initializer {
            try resolve(initializer)
        }
        
        declare(stmt.name)
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
                // TODO: Right now we have no scopes other than the global scope.
                return
            }
        }
        
        // Not found. Assume it is global.
    }
    
    func define(_ name: Token) {
        guard var currentScope = scopes.peek() else {
            return
        }
        
        currentScope[name.lexeme] = false
    }
    
    func declare(_ name: Token) {
        guard var currentScope = scopes.peek() else {
            return
        }
        
        currentScope[name.lexeme] = true
    }
    
    func beginScope() {
        scopes.push([:])
    }
    
    func endScope() {
        scopes.pop()
    }
}
