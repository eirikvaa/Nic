//
//  Resolver.swift
//  Nic
//
//  Created by Eirik Vale Aase on 23/03/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

import Foundation

struct Resolver {
    let irGenerator: IRGenerator
    
    init() {
        irGenerator = IRGenerator()
    }
}

extension Resolver: ExprVisitor {
    func visitLiteralExpr(expr: Expr.Literal) throws {}
    
    func visitBinaryExpr(expr: Expr.Binary) throws {
        try resolve(expr.leftValue)
        try resolve(expr.rightValue)
    }
    
    func visitVariableExpr(expr: Expr.Variable) throws -> () {
        
    }
}

extension Resolver: StmtVisitor {
    func visitVarStmt(_ stmt: Stmt.Var) throws {
        irGenerator.addGlobalVariable(declaration: stmt)
        
        if let initializer = stmt.initializer {
            try resolve(initializer)
        }
    }
    
    func visitPrintStmt(_ stmt: Stmt.Print) throws {
        if let value = stmt.value {
            try resolve(value)
        }
        
        switch stmt.value {
        case let literal as Expr.Literal:
            print(literal.value ?? "")
        case let variable as Expr.Variable:
            print(variable.name?.lexeme ?? "")
        case let addition as Expr.Binary:
            print(addition.leftValue, addition.operator.lexeme, addition.rightValue)
        default:
            print()
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
}
