//
//  Expr.swift
//  Nic
//
//  Created by Eirik Vale Aase on 23/03/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

import Foundation

protocol ExprVisitor {
    associatedtype ExprVisitorReturn
    
    func visitLiteralExpr(expr: Expr.Literal) throws -> ExprVisitorReturn
    func visitBinaryExpr(expr: Expr.Binary) throws -> ExprVisitorReturn
}

class Expr {
    func accept<V: ExprVisitor, R>(visitor: V) throws -> R where R == V.ExprVisitorReturn {
        fatalError("Don't call this directly, must be implemented.")
    }
    
    class Literal: Expr {
        let value: Any?
        
        init(value: Any?) {
            self.value = value
        }
        
        override func accept<V, R>(visitor: V) throws -> R where V : ExprVisitor, R == V.ExprVisitorReturn {
            return try visitor.visitLiteralExpr(expr: self)
        }
    }
    
    class Binary: Expr {
        let leftValue: Expr
        let `operator`: Token
        let rightValue: Expr
        
        init(leftValue: Expr, operator: Token, rightValue: Expr) {
            self.leftValue = leftValue
            self.operator = `operator`
            self.rightValue = rightValue
        }
        
        override func accept<V, R>(visitor: V) throws -> R where V : ExprVisitor, R == V.ExprVisitorReturn {
            return try visitor.visitBinaryExpr(expr: self)
        }
    }
}
