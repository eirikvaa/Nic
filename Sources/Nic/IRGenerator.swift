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
class IRGenerator {
    let module: Module
    let builder: IRBuilder
    let mainFunction: Function
    var blocks: Stack<BasicBlock> = []
    let environment = Environment.shared
    
    init(environment: [String: Any?] = [:]) {
        module = Module(name: "main")
        builder = IRBuilder(module: module)
        
        let mainType = FunctionType(argTypes: [], returnType: VoidType())
        mainFunction = builder.addFunction("main", type: mainType)
    }
    
    func addGlobalVariable(declaration: Stmt.Var) {
        let stmtName = declaration.name.lexeme
        
        var value: Any?
        if let initializer = declaration.initializer {
            value = try? evaluate(initializer)
            buildGlobal(name: stmtName, value: value)
        }
    }
    
    func buildGlobal(name: String, value: Any?) {
        switch value {
        case let str as String:
            let _ = builder.addGlobalString(name: name, value: str)
        case let num as Int:
            let irValue = IntType.int64.constant(num)
            let _ = builder.addGlobal(name, initializer: irValue)
        case let bool as Bool:
            let _ = builder.addGlobal(name, initializer: bool)
        default:
            break
        }
    }
}

extension IRGenerator: ExprVisitor {
    func visitUnaryExpr(expr: Expr.Unary) throws -> Any? {
        let value = try evaluate(expr)
        
        switch expr.operator.type {
        case .minus:
            if var num = value as? Int {
                return num.negate()
            }
        default:
            break
        }
        
        return nil
    }
    
    func visitVariableExpr(expr: Expr.Variable) throws -> Any? {
        return nil
    }
    
    func visitBinaryExpr(expr: Expr.Binary) throws -> Any? {
        let lhs = try evaluate(expr.leftValue)
        let rhs = try evaluate(expr.rightValue)
        
        switch (lhs, expr.operator.type, rhs) {
        case (let lhsNum as Int, .plus, let rhsNum as Int):
            return lhsNum + rhsNum
        case (let lhsNum as Int, .minus, let rhsNum as Int):
            return lhsNum - rhsNum
        case (let lhsNum as Int, .star, let rhsNum as Int):
            return lhsNum * rhsNum
        case (let lhsStr as String, .plus, let rhsStr as String):
            return lhsStr + rhsStr
        default:
            return nil
        }
    }
    
    func visitLiteralExpr(expr: Expr.Literal) throws -> Any? {
        return expr.value
    }
}

extension IRGenerator: StmtVisitor {
    func visitBlockStmt(_ stmt: Stmt.Block) throws {
        let blockCount = mainFunction.basicBlocks.underestimatedCount + 1
        let bb = mainFunction.appendBasicBlock(named: "block_\(blockCount)")
        builder.positionAtEnd(of: bb)
        blocks.push(bb)
        
        try generate(stmt.statements)
        
        if let firstBlock = mainFunction.firstBlock {
            builder.positionAtEnd(of: firstBlock)
        }
        
        blocks.pop()
    }
    
    func visitVarStmt(_ stmt: Stmt.Var) throws {
        let isGlobalScope = blocks.count == 0
        
        let name = stmt.name.lexeme
        var value: Any?
        if let initializer = stmt.initializer {
            value = try evaluate(initializer)
        }
        
        if isGlobalScope {
            addGlobalVariable(declaration: stmt)
        } else {
            switch value {
            case let number as Int:
                let irValue = builder.buildAlloca(type: IntType.int64, count: 1, alignment: .zero, name: name)
                builder.buildStore(number, to: irValue)
            case let boolean as Bool:
                let irValue = builder.buildAlloca(type: IntType.int1, count: 1, alignment: .zero, name: name)
                builder.buildStore(boolean, to: irValue)
            case let string as String:
                _ = builder.addGlobalString(name: name, value: string)
            default:
                break
            }
        }
    }
    
    func visitPrintStmt(_ stmt: Stmt.Print) throws {
        guard let expr = stmt.value else {
            return
        }
        
        let value = try evaluate(expr)
        
        switch value {
        case let number as Int:
            print(number)
        case let string as String:
            print(string)
        case let boolean as Bool:
            print(boolean)
        default:
            print(value ?? "")
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
    
    func evaluate(_ expr: Expr) throws -> Any? {
        return try expr.accept(visitor: self)
    }
}
