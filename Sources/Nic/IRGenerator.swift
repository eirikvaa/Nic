//
//  IRGenerator.swift
//  Nic
//
//  Created by Eirik Vale Aase on 23/03/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

import LLVM

/// `IRGenerator` will traverse the abstract syntax tree and generate LLVM IR, which stands for
/// (Low-Level Virtual Machine Intermediate Representation).
class IRGenerator {
    let module: Module
    let builder: IRBuilder
    let mainFunction: Function
    var blocks: Stack<BasicBlock> = []
    let globals = Environment()
    private var environment: Environment
    private var locals: [Expr: Int] = [:]
    
    init(environment: [String: Any?] = [:]) {
        module = Module(name: "main")
        builder = IRBuilder(module: module)
        
        let mainType = FunctionType(argTypes: [], returnType: VoidType())
        mainFunction = builder.addFunction("main", type: mainType)
        
        let entry = mainFunction.appendBasicBlock(named: "entry")
        builder.positionAtEnd(of: entry)
        
        self.environment = globals
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
    
    func buildVarStmt(name: String, value: Any?) {
        switch value {
        case let number as Int:
            let irValue = builder.buildAlloca(type: IntType.int64, name: name)
            builder.buildStore(number, to: irValue)
        case let boolean as Bool:
            let irValue = builder.buildAlloca(type: IntType.int1, name: name)
            builder.buildStore(boolean, to: irValue)
        case let string as String:
            _ = builder.addGlobalString(name: name, value: string)
        default:
            break
        }
    }
}

extension IRGenerator: ExprVisitor {
    func visitUnaryExpr(expr: Expr.Unary) throws -> Any? {
        let value = try evaluate(expr.value)
        
        switch expr.operator.type {
        case .minus:
            if let num = value as? Int {
                return num * -1
            }
        default:
            break
        }
        
        return nil
    }
    
    func visitVariableExpr(expr: Expr.Variable) throws -> Any? {
        guard let name = expr.name else {
            return nil
        }
        
        return try lookUpVariable(name: name, expr: expr)
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
        /*let blockCount = mainFunction.basicBlocks.underestimatedCount + 1
        let bb = mainFunction.appendBasicBlock(named: "block_\(blockCount)")
        builder.positionAtEnd(of: bb)
        blocks.push(bb)
        
        try generate(stmt.statements)
        
        if let firstBlock = mainFunction.firstBlock {
            builder.positionAtEnd(of: firstBlock)
        }
        
        blocks.pop()
        */
        // Start generating code for the block we're about to visit.
        // We create a new environment which has the current environment as its enclosing environment.
        try generateBlock(stmt.statements, environment: Environment(environment: environment))
    }
    
    func visitVarStmt(_ stmt: Stmt.Var) throws {
        let name = stmt.name.lexeme
        var value: Any?
        if let initializer = stmt.initializer {
            value = try evaluate(initializer)
        }
        
        environment.define(name: name, value: value)
        
        buildVarStmt(name: name, value: value)
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
    func generateBlock(_ statements: [Stmt], environment: Environment) throws {
        let previous = environment
        
        defer {
            self.environment = previous
        }
        
        self.environment = environment
        
        try generate(statements)
    }
    
    func resolve(expr: Expr, depth: Int) {
        locals[expr] = depth
    }
    
    func lookUpVariable(name: Token, expr: Expr) throws -> Any? {
        if let distance = locals[expr] {
            return environment.get(at: distance, name: name.lexeme)
        } else {
            return try globals.get(name: name)
        }
    }
    
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
