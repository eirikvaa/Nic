//
//  CodeGenerator.swift
//  Nic
//
//  Created by Eirik Vale Aase on 23/03/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//
/*
import LLVM

/// `CodeGenerator` will traverse the abstract syntax tree and generate LLVM IR, which stands for
/// (Low-Level Virtual Machine Intermediate Representation).
class CodeGenerator {
    
    /// `Context` is used to signal what state the code generator is currently in.
    /// If it has just started generating code for an conditional branch, then `branch`
    /// will be the context.
    private enum Context {
        case branch
        case none
    }
    
    private let module: Module
    private let builder: IRBuilder
    private let mainFunction: Function
    private let symbolTable = SymbolTable.shared
    private var blockCounter = 0
    private var context: Context = .none
    
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
    
    func verifyLLVMIR() throws {
        try builder.module.verify()
    }
    
    func createLLVMIRFile(fileName: String) {
        do {
            try builder.module.print(to: "/Users/eirik/Documents/Utvikling/macOS/Nic/Sources/Nic/\(fileName).ll")
        } catch {
            print(error)
        }
    }
    
    func generate(_ statements: [Stmt]) throws {
        for stmt in statements {
            try generate(stmt)
        }
        
        if context == .none {
            builder.buildRetVoid()
        }
        
    }
}

// MARK: ExprVisitor

extension CodeGenerator: ExprVisitor {
    func visitLogicalExpr(expr: Expr.Logical) throws -> Any? {
        let leftValue = try evaluate(expr.left) as? Bool ?? false
        let rightValue = try evaluate(expr.right) as? Bool ?? false
        
        switch expr.op.type {
        case .and: return leftValue && rightValue
        case .or: return leftValue || rightValue
        default: return nil
        }
    }
    
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
        case .bang:
            if let boolean = value as? Bool {
                return boolean
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
        
        if expr.operator.type.isLogical {
            return performLogicalOperation(lhs: lhs, op: expr.operator.type, rhs: rhs)
        }
        
        if expr.operator.type.isComparison {
            return performComparisonOperation(lhs: lhs, op: expr.operator.type, rhs: rhs)
        }
        
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
    func visitIfStatement(_ stmt: Stmt.If) throws {
        let oldContext = context
        context = .branch
        
        let value = try evaluate(stmt.condition)
        
        guard let condition = value as? Bool else {
            return
        }
        
        let test = builder.buildICmp(condition, true, .equal)
        let thenBB = mainFunction.appendBasicBlock(named: "then\(blockCounter)")
        let elseBB = mainFunction.appendBasicBlock(named: "else\(blockCounter)")
        let mergeBB = mainFunction.appendBasicBlock(named: "merge\(blockCounter)")
        
        builder.buildCondBr(condition: test, then: thenBB, else: elseBB)
        
        builder.positionAtEnd(of: thenBB)
        
        if condition {
            try generate(stmt.ifBranch)
        }
        
        builder.positionAtEnd(of: thenBB)
        builder.buildBr(mergeBB)
        
        builder.positionAtEnd(of: elseBB)
        
        if !condition {
            if let elseBranch = stmt.elseBranch {
                try generate(elseBranch)
            }
        }
        
        builder.buildBr(mergeBB)
        builder.positionAtEnd(of: mergeBB)
        
        let phi = builder.buildPhi(IntType.int1)
        phi.addIncoming([
            (IntType.int1.zero(), thenBB),
            (IntType.int1.zero(), elseBB)
        ])
        
        context = oldContext
    }
    
    func visitExpressionStatement(_ stmt: Stmt.Expression) throws {
        _ = try evaluate(stmt.expression)
    }
    
    func visitConstStmt(_ stmt: Stmt.Const) throws {
        let depth = stmt.initializer.depth
        try buildVarStmt(name: stmt.name, at: depth)
    }
    
    func visitBlockStmt(_ stmt: Stmt.Block) throws {
        blockCounter += 1
        try generate(stmt.statements)
    }
    
    func visitVarStmt(_ stmt: Stmt.Var) throws {
        let depth = stmt.initializer?.depth ?? 0
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
    
    func performComparisonOperation(lhs: Any?, op: TokenType, rhs: Any?) -> Any? {
        guard let lhsValue = lhs as? Int, let rhsValue = rhs as? Int else {
            return nil
        }
        
        switch op {
        case .equal_equal: return lhsValue == rhsValue
        case .bang_equal: return lhsValue != rhsValue
        case .greater_equal: return lhsValue >= rhsValue
        case .greater: return lhsValue > rhsValue
        case .less_equal: return lhsValue <= rhsValue
        case .less: return lhsValue < rhsValue
        default: return nil
        }
    }
    
    func performLogicalOperation(lhs: Any?, op: TokenType, rhs: Any?) -> Any? {
        guard let lhsValue = lhs as? Bool, let rhsValue = rhs as? Bool else {
            return nil
        }
        
        switch op {
        case .and:
            _ = builder.buildAnd(lhsValue, rhsValue)
        case .or:
            _ = builder.buildOr(lhsValue, rhsValue)
        default:
            break
        }
        
        return nil
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
*/
