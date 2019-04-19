//
//  Expr.swift
//  Nic
//
//  Created by Eirik Vale Aase on 23/03/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

protocol ExprVisitor {
    associatedtype ExprVisitorReturn
    
    func visitLiteralExpr(expr: Expr.Literal) throws -> ExprVisitorReturn
    func visitAssignExpr(expr: Expr.Assign) throws -> ExprVisitorReturn
    func visitBinaryExpr(expr: Expr.Binary) throws -> ExprVisitorReturn
    func visitVariableExpr(expr: Expr.Variable) throws -> ExprVisitorReturn
    func visitUnaryExpr(expr: Expr.Unary) throws -> ExprVisitorReturn
    func visitGroupExpr(expr: Expr.Group) throws -> ExprVisitorReturn
}

/// `Expr` implements `ExprVisitor`, making it possible to traverse the expression nodes in the tree.
/// Together with `Stmt`, since it implements `StmtVisitor`, one can walk the entire abstract syntax tree.
class Expr {
    func accept<V: ExprVisitor, R>(visitor: V) throws -> R where R == V.ExprVisitorReturn {
        fatalError("Don't call this directly, must be implemented.")
    }
    
    class Literal: Expr {
        let value: Any?
        var type: NicType?
        
        init(value: Any?) {
            self.value = value
        }
        
        override func accept<V, R>(visitor: V) throws -> R where V : ExprVisitor, R == V.ExprVisitorReturn {
            return try visitor.visitLiteralExpr(expr: self)
        }
    }
    
    class Assign: Expr {
        let name: Token
        let value: Expr
        
        init(name: Token, value: Expr) {
            self.name = name
            self.value = value
        }
        
        override func accept<V, R>(visitor: V) throws -> R where V : ExprVisitor, R == V.ExprVisitorReturn {
            return try visitor.visitAssignExpr(expr: self)
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
    
    class Variable: Expr {
        let name: Token?
        var type: NicType?
        
        init(name: Token?) {
            self.name = name
        }
        
        override func accept<V, R>(visitor: V) throws -> R where V : ExprVisitor, R == V.ExprVisitorReturn {
            return try visitor.visitVariableExpr(expr: self)
        }
    }
    
    class Unary: Expr {
        let `operator`: Token
        let value: Expr
        
        init(`operator`: Token, value: Expr) {
            self.operator = `operator`
            self.value = value
        }
        
        override func accept<V, R>(visitor: V) throws -> R where V : ExprVisitor, R == V.ExprVisitorReturn {
            return try visitor.visitUnaryExpr(expr: self)
        }
    }
    
    class Group: Expr {
        let value: Expr
        
        init(value: Expr) {
            self.value = value
        }
        
        override func accept<V, R>(visitor: V) throws -> R where V : ExprVisitor, R == V.ExprVisitorReturn {
            return try visitor.visitGroupExpr(expr: self)
        }
    }
}

extension Expr: Hashable {
    static func ==(lhs: Expr, rhs: Expr) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
