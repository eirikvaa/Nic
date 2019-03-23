//
//  Stmt.swift
//  Nic
//
//  Created by Eirik Vale Aase on 23/03/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

import Foundation

protocol StmtVisitor {
    associatedtype StmtVisitorReturn
    
    func visitVarStmt(_ stmt: Stmt.Var) throws -> StmtVisitorReturn
}

class Stmt {
    func accept<V: StmtVisitor, R>(visitor: V) throws -> R where R == V.StmtVisitorReturn {
        fatalError("Don't call this directly, must be implemented.")
    }
    
    class Var: Stmt {
        let name: Token
        let initializer: Expr?
        
        init(name: Token, initializer: Expr?) {
            self.name = name
            self.initializer = initializer
        }
        
        override func accept<V, R>(visitor: V) throws -> R where V : StmtVisitor, R == V.StmtVisitorReturn {
            return try visitor.visitVarStmt(self)
        }
    }
}