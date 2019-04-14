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
struct Resolver {}

extension Resolver: ExprVisitor {
    func visitLiteralExpr(expr: Expr.Literal) throws {}
    
    func visitBinaryExpr(expr: Expr.Binary) throws {
        try resolve(expr.leftValue)
        try resolve(expr.rightValue)
    }
    
    func visitVariableExpr(expr: Expr.Variable) throws {
        // TODO: Resolve the variable expression
    }
}

extension Resolver: StmtVisitor {
    func visitVarStmt(_ stmt: Stmt.Var) throws {
        // TODO: Declare the variable
        
        if let initializer = stmt.initializer {
            try resolve(initializer)
        }
        
        // TODO: Define the variable
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
}
