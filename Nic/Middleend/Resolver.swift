//
//  Resolver.swift
//  Nic
//
//  Created by Eirik Vale Aase on 23/03/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

/// `Resolver` traverses the abstract syntax tree and resolves any global and local variables.
class Resolver {
    private var scopeDepth = 0
    private let symbolTable = SymbolTable.shared
    
    func resolve(_ statements: [Stmt]) throws {
        for stmt in statements {
            try resolve(stmt)
        }
    }
}

extension Resolver: ExprVisitor {
    func visitLogicalExpr(expr: Expr.Logical) throws {
        try resolve(expr.left)
        try resolve(expr.right)
    }
    
    func visitAssignExpr(expr: Expr.Assign) throws {
        try resolve(expr.value)
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
        
        if try symbolTable.get(name: name, at: expr.depth, keyPath: \.isDefined) == false {
            Nic.error(token: name, message: "Variable '\(name.lexeme)' used inside its own initializer.")
        }
    }
}

extension Resolver: StmtVisitor {
    func visitIfStatement(_ stmt: Stmt.If) throws {
        try resolve(stmt.condition)
        try resolve(stmt.ifBranch)
        
        if let elseBranch = stmt.elseBranch {
            try resolve(elseBranch)
        }
    }
    
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
    
    func declare(_ name: Token, mutable: Bool) {
        do {
            if try symbolTable.get(name: name, at: scopeDepth, keyPath: \.isDefined) == true {
                Nic.error(token: name, message: "Variable '\(name.lexeme)' is already declared in this scope.")
            }
        } catch {
            return
        }
        
        symbolTable.set(element: false, at: \.isDefined, to: name, at: scopeDepth)
    }
    
    func define(_ name: Token) {
        symbolTable.set(element: true, at: \.isDefined, to: name, at: scopeDepth)
    }
    
    func beginScope() {
        scopeDepth += 1
    }
    
    func endScope() {
        scopeDepth -= 1
    }
}
