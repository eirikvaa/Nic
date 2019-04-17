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
    func visitVarStmt(_ stmt: Stmt.Var) throws {
        if let initializer = stmt.initializer {
            switch initializer {
            case let literal as Expr.Literal:
                if stmt.type != literal.type {
                    if let stmtType = stmt.type, let literalType = literal.type {
                        let msg = "'\(stmt.name.lexeme)' was initialized with a value of type '\(literalType.rawValue)', but expected a value of type '\(stmtType.rawValue)' instead."
                        CommandLineParser.error(at: stmt.name.line, message: msg)
                    }
                }
            case let binary as Expr.Binary:
                try typecheck(binary)
            default:
                break
            }
        }
    }
    
    func visitPrintStmt(_ stmt: Stmt.Print) throws {
        if let value = stmt.value {
            try typecheck(value)
        }
    }
}

extension TypeChecker: ExprVisitor {
    func visitAssignExpr(expr: Expr.Assign) throws {}
    
    func visitLiteralExpr(expr: Expr.Literal) throws {}
    
    func visitBinaryExpr(expr: Expr.Binary) throws {
        let lhsType = expr.leftExprType()
        let rhsType = expr.rightExprType()
        switch (expr.operator.type) {
            case .star,
                 .minus,
                 .slash:
            switch (lhsType, rhsType) {
                case (.numberType?, .numberType?):
                    break
                default:
                    CommandLineParser.error(at: expr.operator.line, message: "Trying to perform mathematical operations on a value of type '\(lhsType!.rawValue)' and a value of type '\(rhsType!.rawValue)'")
                }
            case .plus:
            switch (lhsType, rhsType) {
                case (.numberType?, .numberType?),
                     (.stringType?, .stringType?):
                    break
            default:
                CommandLineParser.error(at: expr.operator.line, message: "Trying to add a value of type '\(lhsType!.rawValue)' with a value of type '\(rhsType!.rawValue)'")
            }
        default:
            break
        }
    }
    
    func visitVariableExpr(expr: Expr.Variable) throws {}
}
