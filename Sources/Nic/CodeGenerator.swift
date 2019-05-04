//
//  CodeGenerator.swift
//  Nic
//
//  Created by Eirik Vale Aase on 23/03/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

import LLVM

/// `CodeGenerator` will traverse the abstract syntax tree and generate LLVM IR, which stands for
/// (Low-Level Virtual Machine Intermediate Representation).
class CodeGenerator {
    private let module: Module
    private let builder: IRBuilder
    private let mainFunction: Function
    private var blocks: [BasicBlock] = []
    private let symbolTable = SymbolTable.shared
    
    init() {
        module = Module(name: "main")
        builder = IRBuilder(module: module)
        
        let mainType = FunctionType(argTypes: [], returnType: VoidType())
        mainFunction = builder.addFunction("main", type: mainType)
        
        let entry = mainFunction.appendBasicBlock(named: "entry")
        builder.positionAtEnd(of: entry)
    }
    
    func dumpLLVMIR() {
        builder.module.dump()
    }
    
    func generate(_ statements: [Stmt]) throws {
        for stmt in statements {
            try generate(stmt)
        }
    }
}

// MARK: ExprVisitor

extension CodeGenerator: ExprVisitor {
    func visitAssignExpr(expr: Expr.Assign) throws -> Any? {
        let value = try evaluate(expr.value)
        
        let isMutable = try symbolTable.get(name: expr.name, at: expr.depth, keyPath: \.isMutable) ?? false
        
        guard isMutable else {
            throw NicRuntimeError.illegalConstantMutation(name: expr.name)
        }
        
        symbolTable.set(element: value, at: \.value, to: expr.name, at: expr.depth)
        
        return nil
    }
    
    func visitGroupExpr(expr: Expr.Group) throws -> Any? {
        return try evaluate(expr.value)
    }
    
    func visitUnaryExpr(expr: Expr.Unary) throws -> Any? {
        let value = try evaluate(expr.value)
        
        switch expr.operator.type {
        case .minus:
            if let integer = value as? Int {
                return integer * -1
            } else if let double = value as? Double {
                return double * -1.0
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
        
        let numericOperation = expr.operator.type != .slash
        let op = expr.operator.lexeme
        
        return numericOperation ?
            performNumericOperation(lhs: lhs, op: op, rhs: rhs) :
            performDivisionOperation(lhs: lhs, rhs: rhs)
    }
    
    func visitLiteralExpr(expr: Expr.Literal) throws -> Any? {
        return expr.value
    }
}

// MARK: StmtVisitor

extension CodeGenerator: StmtVisitor {
    func visitExpressionStatement(_ stmt: Stmt.Expression) throws {
        _ = try evaluate(stmt.expression)
    }
    
    func visitConstStmt(_ stmt: Stmt.Const) throws {
        // TODO: Swap with LLVM IR constant expression, if it exists?
        // buildConstStmt will update the nameInformation variable with the IRValue, so defining it in the
        // environment must happen after the aforementioned call.
        let value = try evaluate(stmt.initializer)
        let depth = stmt.initializer.depth
        symbolTable.set(element: value, at: \.value, to: stmt.name, at: depth)
        try buildVarStmt(name: stmt.name, at: stmt.initializer.depth)
    }
    
    func visitBlockStmt(_ stmt: Stmt.Block) throws {
        // Start generating code for the block we're about to visit.
        // We create a new environment which has the current environment as its enclosing environment.
        try generateBlock(stmt.statements)
    }
    
    func visitVarStmt(_ stmt: Stmt.Var) throws {
        var value: Any?
        if let initializer = stmt.initializer {
            value = try evaluate(initializer)
        }
        
        let depth = stmt.initializer?.depth ?? 0
        symbolTable.set(element: value, at: \.value, to: stmt.name, at: depth)
        try buildVarStmt(name: stmt.name, at: depth)
    }
    
    func visitPrintStmt(_ stmt: Stmt.Print) throws {
        guard let expr = stmt.value else {
            return
        }
        
        let value = try evaluate(expr)
        
        switch value {
        case let integer as Int:
            print(integer)
        case let double as Double:
            print(double)
        case let string as String:
            print(string)
        case let boolean as Bool:
            print(boolean)
        default:
            print(value ?? "")
        }
    }
}

// MARK: Private helpers

private extension CodeGenerator {
    func buildVarStmt(name: Token, at distance: Int) throws {
        let value = try symbolTable.get(name: name, at: distance, keyPath: \.value) ?? nil
        
        switch value {
        case let number as Int:
            let irValue = builder.buildAlloca(type: IntType.int64, name: name.lexeme)
            builder.buildStore(number, to: irValue)
        case let double as Double:
            let doubleIRValue = FloatType.double.constant(double)
            let irValue = builder.buildAlloca(type: FloatType.double, name: name.lexeme)
            builder.buildStore(doubleIRValue, to: irValue)
        case let boolean as Bool:
            let irValue = builder.buildAlloca(type: IntType.int1, name: name.lexeme)
            builder.buildStore(boolean, to: irValue)
        case let string as String:
            _ = builder.addGlobalString(name: name.lexeme, value: string)
        default:
            break
        }
    }
    
    func performNumericOperation(lhs: Any?, op: String, rhs: Any?) -> Any? {
        switch (lhs, rhs) {
        case (let intA as Int, let intB as Int):
            return performOperation(lhs: intA, op: op, rhs: intB)
        case (let doubleA as Double, let doubleB as Double):
            return performOperation(lhs: doubleA, op: op, rhs: doubleB)
        case (let intA as Int, let doubleB as Double):
            return performOperation(lhs: Double(intA), op: op, rhs: doubleB)
        case (let doubleA as Double, let intB as Int):
            return performOperation(lhs: doubleA, op: op, rhs: Double(intB))
        default:
            return nil
        }
    }
    
    func performDivisionOperation(lhs: Any?, rhs: Any?) -> Any? {
        switch (lhs, rhs) {
        case (let intA as Int, let intB as Int):
            return performDivisionOperation(lhs: intA, rhs: intB)
        case (let doubleA as Double, let doubleB as Double):
            return performDivisionOperation(lhs: doubleA, rhs: doubleB)
        case (let intA as Int, let doubleB as Double):
            return performDivisionOperation(lhs: Double(intA), rhs: doubleB)
        case (let doubleA as Double, let intB as Int):
            return performDivisionOperation(lhs: doubleA, rhs: Double(intB))
        default:
            return nil
        }
    }
    
    func performOperation<T: Numeric>(lhs: T, op: String, rhs: T) -> T {
        switch op {
        case "+": return lhs + rhs
        case "-": return lhs - rhs
        case "*": return lhs * rhs
        default: return 0
        }
    }
    
    func performDivisionOperation(lhs: Int, rhs: Int) -> Double {
        return Double(lhs / rhs)
    }
    
    func performDivisionOperation(lhs: Double, rhs: Double) -> Double {
        return lhs / rhs
    }
    
    func generateBlock(_ statements: [Stmt]) throws {
        let blockCount = mainFunction.basicBlocks.underestimatedCount + 1
        let bb = mainFunction.appendBasicBlock(named: "block_\(blockCount)")
        builder.positionAtEnd(of: bb)
        blocks.append(bb)
        
        try generate(statements)
        
        if let firstBlock = mainFunction.firstBlock {
            builder.positionAtEnd(of: firstBlock)
        }
        
        _ = blocks.popLast()
    }
    
    func lookUpVariable(name: Token, expr: Expr) throws -> Any? {
        return try symbolTable.get(name: name, at: expr.depth, keyPath: \.value) ?? nil
    }
    
    func generate(_ stmt: Stmt) throws {
        try stmt.accept(visitor: self)
    }
    
    func evaluate(_ expr: Expr) throws -> Any? {
        return try expr.accept(visitor: self)
    }
}
