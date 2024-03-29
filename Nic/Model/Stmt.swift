//
//  Stmt.swift
//  Nic
//
//  Created by Eirik Vale Aase on 23/03/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

protocol StmtVisitor {
    associatedtype StmtVisitorReturn

    func visitVarStmt(_ stmt: Stmt.Var) throws -> StmtVisitorReturn
    func visitConstStmt(_ stmt: Stmt.Const) throws -> StmtVisitorReturn
    func visitPrintStmt(_ stmt: Stmt.Print) throws -> StmtVisitorReturn
    func visitBlockStmt(_ stmt: Stmt.Block) throws -> StmtVisitorReturn
    func visitExpressionStatement(_ stmt: Stmt.Expression) throws -> StmtVisitorReturn
    func visitIfStatement(_ stmt: Stmt.If) throws -> StmtVisitorReturn
}

/// `Stmt` implements `StmtVisitor`, making it possible to traverse the statement nodes in the tree.
/// Together with `Expr`, since it implements `ExprVisitor`, one can walk the entire abstract syntax tree.
class Stmt {
    func accept<V: StmtVisitor, R>(visitor _: V) throws -> R where R == V.StmtVisitorReturn {
        fatalError("Don't call this directly, must be implemented.")
    }

    class Var: Stmt {
        let name: Token
        let type: NicType?
        let initializer: Expr?

        init(name: Token, type: NicType?, initializer: Expr?) {
            self.name = name
            self.type = type
            self.initializer = initializer
        }

        override func accept<V, R>(visitor: V) throws -> R where V: StmtVisitor, R == V.StmtVisitorReturn {
            return try visitor.visitVarStmt(self)
        }
    }

    class Const: Stmt {
        let name: Token
        let type: NicType?
        let initializer: Expr

        init(name: Token, type: NicType?, initializer: Expr) {
            self.name = name
            self.type = type
            self.initializer = initializer
        }

        override func accept<V, R>(visitor: V) throws -> R where V: StmtVisitor, R == V.StmtVisitorReturn {
            return try visitor.visitConstStmt(self)
        }
    }

    class Print: Stmt {
        let value: Expr?

        init(value: Expr?) {
            self.value = value
        }

        override func accept<V, R>(visitor: V) throws -> R where V: StmtVisitor, R == V.StmtVisitorReturn {
            return try visitor.visitPrintStmt(self)
        }
    }

    class Block: Stmt {
        let statements: [Stmt]

        init(statements: [Stmt]) {
            self.statements = statements
        }

        override func accept<V, R>(visitor: V) throws -> R where V: StmtVisitor, R == V.StmtVisitorReturn {
            return try visitor.visitBlockStmt(self)
        }
    }

    class Expression: Stmt {
        let expression: Expr

        init(expression: Expr) {
            self.expression = expression
        }

        override func accept<V, R>(visitor: V) throws -> R where V: StmtVisitor, R == V.StmtVisitorReturn {
            return try visitor.visitExpressionStatement(self)
        }
    }

    class If: Stmt {
        let condition: Expr
        let ifBranch: Stmt
        let elseBranch: Stmt?

        init(condition: Expr, ifBranch: Stmt, elseBranch: Stmt?) {
            self.condition = condition
            self.ifBranch = ifBranch
            self.elseBranch = elseBranch
        }

        override func accept<V, R>(visitor: V) throws -> R where V: StmtVisitor, R == V.StmtVisitorReturn {
            return try visitor.visitIfStatement(self)
        }
    }
}
