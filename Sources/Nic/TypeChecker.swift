//
//  TypeChecker.swift
//  Nic
//
//  Created by Eirik Vale Aase on 15/04/2019.
//

import Foundation

struct TypeChecker {
    func typecheck(_ statements: [Stmt]) throws {
        for stmt in statements {
            try stmt.accept(visitor: self)
        }
    }
    
    func typecheck(_ stmt: Stmt) throws {
        try stmt.accept(visitor: self)
    }
    
    func typecheck(_ expr: Expr) throws {
        try expr.accept(visitor: self)
    }
}

extension TypeChecker: StmtVisitor {
    func visitBlockStmt(_ stmt: Stmt.Block) throws {
        for stmt in stmt.statements {
            try typecheck(stmt)
        }
    }
    
    func visitVarStmt(_ stmt: Stmt.Var) throws {
        guard let initializer = stmt.initializer else {
            return
        }
        
        try typecheck(initializer)
    }
    
    func visitPrintStmt(_ stmt: Stmt.Print) throws {
        guard let value = stmt.value else {
            return
        }
        
        try typecheck(value)
    }
}

extension TypeChecker: ExprVisitor {
    func visitUnaryExpr(expr: Expr.Unary) throws {
        try typecheck(expr.value)
    }
    
    func visitLiteralExpr(expr: Expr.Literal) throws {}
    
    func visitBinaryExpr(expr: Expr.Binary) throws {
        try typecheck(expr.leftValue)
        try typecheck(expr.rightValue)
    }
    
    func visitVariableExpr(expr: Expr.Variable) throws {}
}
