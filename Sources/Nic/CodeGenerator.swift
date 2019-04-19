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
    
    func buildVarStmt(name: String, nameInformation: NameInformation) {
        
        switch nameInformation.value {
        case let number as Int:
            let irValue = builder.buildAlloca(type: IntType.int64, name: name)
            builder.buildStore(number, to: irValue)
            environment.define(name: name, nameInformation: nameInformation)
        case let double as Double:
            let doubleIRValue = FloatType.double.constant(double)
            let irValue = builder.buildAlloca(type: FloatType.double, name: name)
            builder.buildStore(doubleIRValue, to: irValue)
            environment.define(name: name, nameInformation: nameInformation)
        case let boolean as Bool:
            let irValue = builder.buildAlloca(type: IntType.int1, name: name)
            builder.buildStore(boolean, to: irValue)
            environment.define(name: name, nameInformation: nameInformation)
        case let string as String:
            _ = builder.addGlobalString(name: name, value: string)
            globals.define(name: name, nameInformation: nameInformation)
        default:
            break
        }
    }
    
    func updateVariable(name: String, nameInformation: NameInformation?) {
        // TODO: Not sure if this is the correct way to go about this.
        switch nameInformation?.value {
        case let number as Int:
            _ = builder.buildMalloc(IntType.int64, name: name)
            let irValue = builder.buildAlloca(type: IntType.int64, name: name)
            builder.buildStore(number, to: irValue)
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
    
    func generateBlock(_ statements: [Stmt], environment: Environment) throws {
        let previous = environment
        
        defer {
            self.environment = previous
        }
        
        self.environment = environment
        
        let blockCount = mainFunction.basicBlocks.underestimatedCount + 1
        let bb = mainFunction.appendBasicBlock(named: "block_\(blockCount)")
        builder.positionAtEnd(of: bb)
        blocks.push(bb)
        
        try generate(statements)
        
        if let firstBlock = mainFunction.firstBlock {
            builder.positionAtEnd(of: firstBlock)
        }
        
        blocks.pop()
    }
    
    func resolve(expr: Expr, depth: Int) {
        locals[expr] = depth
    }
    
    func lookUpVariable(name: Token, expr: Expr) throws -> NameInformation? {
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

// MARK: ExprVisitor

extension CodeGenerator: ExprVisitor {
    func visitAssignExpr(expr: Expr.Assign) throws -> Any? {
        var nameInformation = try lookUpVariable(name: expr.name, expr: expr)
        
        if nameInformation?.isMutable == false {
            Nic.error(at: expr.name.line, message: "Cannot mutate constant '\(expr.name.lexeme)'.")
            throw NicRuntimeError.illegalConstantMutation(name: expr.name)
        } else {
            var value: Any? = try evaluate(expr.value)
            
            if let info = value as? NameInformation {
                value = info.value
            }
            
            nameInformation?.value = value
            
            if let distance = locals[expr] {
                environment.assign(at: distance, name: expr.name, value: nameInformation)
            } else {
                try globals.assign(token: expr.name, value: nameInformation)
            }
            
            //updateVariable(name: expr.name.lexeme, nameInformation: nameInformation)
        }
        
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
        var lhs = try evaluate(expr.leftValue)
        var rhs = try evaluate(expr.rightValue)
        
        if let lhsInfo = lhs as? NameInformation {
            lhs = lhsInfo.value
        }
        
        if let rhsInfo = rhs as? NameInformation {
            rhs = rhsInfo.value
        }
        
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
        let name = stmt.name.lexeme
        let value = try evaluate(stmt.initializer)
        
        // TODO: Swap with LLVM IR constant expression, if it exists?
        let nameInformation = NameInformation(value: value, isMutable: false)
        environment.define(name: name, nameInformation: nameInformation)
        buildVarStmt(name: name, nameInformation: nameInformation)
    }
    
    func visitBlockStmt(_ stmt: Stmt.Block) throws {
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
        let nameInformation = NameInformation(value: value, isMutable: true)
        environment.define(name: name, nameInformation: nameInformation)
        
        buildVarStmt(name: name, nameInformation: nameInformation)
    }
    
    func visitPrintStmt(_ stmt: Stmt.Print) throws {
        guard let expr = stmt.value else {
            return
        }
        
        var value = try evaluate(expr)
        
        if let info = value as? NameInformation {
            value = info.value
        }
        
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
