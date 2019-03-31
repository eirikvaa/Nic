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
}

extension Resolver: StmtVisitor {
    func visitVarStmt(_ stmt: Stmt.Var) throws {
        print(stmt.name.lexeme, terminator: " ")
        irGenerator.addGlobalVariable(declaration: stmt)
        switch stmt.initializer {
        case _ as Expr.Literal:
            break
        default:
            break
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
