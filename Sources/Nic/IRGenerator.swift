//
//  IRGenerator.swift
//  Nic
//
//  Created by Eirik Vale Aase on 23/03/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

import Foundation
import LLVM

/// The `IRGenerator` will do a single pass over the tree and generate the LLVM IR.
struct IRGenerator {
    let module: Module
    let builder: IRBuilder
    let mainFunction: Function
    let environment: [String: Any?]
    
    init(environment: [String: Any?] = [:]) {
        self.environment = environment
        
        module = Module(name: "main")
        builder = IRBuilder(module: module)
        
        let mainType = FunctionType(argTypes: [], returnType: VoidType())
        mainFunction = builder.addFunction("main", type: mainType)
        
        let entry = mainFunction.appendBasicBlock(named: "entry")
        builder.positionAtEnd(of: entry)
    }
    
    func addGlobalVariable(declaration: Stmt.Var) {
        let stmtName = declaration.name.lexeme
        
        switch declaration.initializer {
        case let literal as Expr.Literal:
            switch literal.value {
            case let number as Int:
                buildGlobal(name: stmtName, value: number)
            case let string as String:
                buildGlobal(name: stmtName, value: string)
            default:
                break
            }
        case let binary as Expr.Binary:
            switch (binary.leftValue, binary.operator, binary.rightValue) {
            case (let lhs as Expr.Literal, _, let rhs as Expr.Literal):
                switch (lhs.value, binary.operator.lexeme, rhs.value) {
                case (let lhsNumber as Int, "+", let rhsNumber as Int):
                    buildAddOperation(name: stmtName, lhsValue: lhsNumber, rhsValue: rhsNumber)
                case (let lhsNumber as Int, "*", let rhsNumber as Int):
                    buildMulOperation(name: stmtName, lhsValue: lhsNumber, rhsValue: rhsNumber)
                case (let lhsString as String, "+", let rhsString as String):
                    buildAddOperation(name: stmtName, lhsValue: lhsString, rhsValue: rhsString)
                default:
                    break
                }
            case (let lhs as Expr.Variable, _, let rhs as Expr.Literal):
                let lhsValue = environment[lhs.name!.lexeme] ?? nil
                switch (lhsValue, binary.operator.lexeme, rhs.value) {
                case (let lhsNumber as Int, "+", let rhsNumber as Int):
                    buildAddOperation(name: stmtName, lhsValue: lhsNumber, rhsValue: rhsNumber)
                default:
                    break
                }
            case (let lhs as Expr.Variable, _, let rhs as Expr.Variable):
                let lhsValue = environment[lhs.name!.lexeme] ?? nil
                let rhsValue = environment[rhs.name!.lexeme] ?? nil
                switch (lhsValue, binary.operator.lexeme, rhsValue) {
                case (let lhsNumber as Int, "+", let rhsNumber as Int):
                    buildAddOperation(name: stmtName, lhsValue: lhsNumber, rhsValue: rhsNumber)
                case (let lhsString as String, "+", let rhsString as String):
                    buildAddOperation(name: stmtName, lhsValue: lhsString, rhsValue: rhsString)
                default:
                    break
                }
            default:
                break
            }
        default:
            break
        }
    }
    
    func buildGlobal(name: String, value: IRValue) {
        switch value {
        case let str as String:
            let _ = builder.addGlobalString(name: name, value: str)
        case let num as Int:
            let irValue = IntType.int64.constant(num)
            let _ = builder.addGlobal(name, initializer: irValue)
        default:
            fatalError()
        }
    }
    
    func buildAddOperation(name: String, lhsValue: IRValue, rhsValue: IRValue) {
        let add: IRValue
        
        switch (lhsValue, rhsValue) {
        case (let lhsStr as String, let rhsStr as String):
            add = builder.addGlobalString(name: name, value: lhsStr + rhsStr)
        case (is Int, is Int):
            add = builder.buildAdd(lhsValue, rhsValue)
        default:
            fatalError()
        }
        
        let _ = builder.addGlobal(name, initializer: add)
    }
    
    func buildMulOperation(name: String, lhsValue: IRValue, rhsValue: IRValue) {
        let mult = builder.buildMul(lhsValue, rhsValue)
        let _ = builder.addGlobal(name, initializer: mult)
    }
}

extension IRGenerator: ExprVisitor {
    func visitAssignExpr(expr: Expr.Assign) throws {
        return
    }
    
    func visitVariableExpr(expr: Expr.Variable) throws {
        return
    }
    
    func visitBinaryExpr(expr: Expr.Binary) throws {
        return
    }
    
    func visitLiteralExpr(expr: Expr.Literal) throws {
        return
    }
}

extension IRGenerator: StmtVisitor {
    func visitVarStmt(_ stmt: Stmt.Var) throws {
        addGlobalVariable(declaration: stmt)
    }
    
    func visitPrintStmt(_ stmt: Stmt.Print) throws {
        switch stmt.value {
        case let literal as Expr.Literal:
            print(literal.value ?? "")
        case let variable as Expr.Variable:
            print(variable.value() ?? "")
        case let addition as Expr.Binary:
            print(addition.leftValue, addition.operator.lexeme, addition.rightValue)
        default:
            print()
        }
    }
}

extension IRGenerator {
    func generate(_ statements: [Stmt]) throws {
        for stmt in statements {
            try generate(stmt)
        }
    }
    
    func generate(_ stmt: Stmt) throws {
        try stmt.accept(visitor: self)
    }
    
    func generate(_ expr: Expr) throws {
        try expr.accept(visitor: self)
    }
}
