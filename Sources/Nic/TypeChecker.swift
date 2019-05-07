//
//  TypeChecker.swift
//  Nic
//
//  Created by Eirik Vale Aase on 15/04/2019.
//

/// `TypeChecker` would traverse the tree and make sure that the type system is satisfied.
struct TypeChecker {
    private let symbolTable = SymbolTable.shared
    func typecheck(_ statements: [Stmt]) throws {
        for stmt in statements {
            try stmt.accept(visitor: self)
        }
    }
}

extension TypeChecker: StmtVisitor {
    func visitExpressionStatement(_ stmt: Stmt.Expression) throws {
        let _ = try evaluate(stmt.expression)
    }
    
    func visitConstStmt(_ stmt: Stmt.Const) throws {
        let value = try evaluate(stmt.initializer)
        
        if let declarationType = stmt.type,
            let valueType = value.nicType() {
            try typecheckDeclaration(token: stmt.name, declarationType: declarationType, initializedType: valueType)
        }
        
        symbolTable.set(element: value, at: \.value, to: stmt.name, at: stmt.initializer.depth)
    }
    
    func visitBlockStmt(_ stmt: Stmt.Block) throws {
        for stmt in stmt.statements {
            try typecheck(stmt)
        }
    }
    
    func visitVarStmt(_ stmt: Stmt.Var) throws {
        guard let initializer = stmt.initializer else {
            return
        }
        
        let value = try evaluate(initializer)
        
        if let stmtType = stmt.type,
            let valueType = value.nicType() {
            try typecheckDeclaration(token: stmt.name, declarationType: stmtType, initializedType: valueType)
        }
        
        symbolTable.set(element: value, at: \.value, to: stmt.name, at: stmt.initializer?.depth ?? 0)
    }
    
    func visitPrintStmt(_ stmt: Stmt.Print) throws {
        
    }
}

extension TypeChecker: ExprVisitor {
    func visitAssignExpr(expr: Expr.Assign) throws -> Any? {
        let assignmentValue = try evaluate(expr.value)
        let receivingType = try symbolTable.get(name: expr.name, at: expr.depth, keyPath: \.value)?.nicType()
        
        guard assignmentValue.nicType() == receivingType else {
            Nic.error(at: expr.depth, message: "Can't assign a value of type '\(assignmentValue) to a variable of type '\(receivingType)'")
            throw NicError.invalidAssignment
        }
        
        symbolTable.set(element: assignmentValue, at: \.value, to: expr.name, at: expr.depth)
        
        return assignmentValue
    }
    
    func visitGroupExpr(expr: Expr.Group) throws -> Any? {
        return try evaluate(expr.value)
    }
    
    func visitUnaryExpr(expr: Expr.Unary) throws -> Any?  {
        return try evaluate(expr.value)
    }
    
    func visitLiteralExpr(expr: Expr.Literal) throws -> Any? {
        return expr.value
    }
    
    func visitBinaryExpr(expr: Expr.Binary) throws -> Any? {
        let lhs = try evaluate(expr.leftValue)
        let rhs = try evaluate(expr.rightValue)
        
        let lhsType = lhs.nicType()
        let operationType = expr.operator.type
        let rhsType = rhs.nicType()
        
        if !validOperands(operand1: lhs, operand2: rhs, for: operationType) {
            Nic.error(at: expr.operator.line, message: "Tried to perform a '\(operationType)' operation on operands of type '\(lhsType)' and '\(rhsType)'")
        }
        
        return evaluateOperation(operationType: operationType, with: lhs, rhs: rhs)
    }
    
    func visitVariableExpr(expr: Expr.Variable) throws -> Any? {
        guard let name = expr.name else {
            return nil
        }
        
        return try symbolTable.get(name: name, at: expr.depth, keyPath: \.value) ?? nil
    }
    
    typealias ExprVisitorReturn = Any?
}

private extension TypeChecker {
    func typecheck(_ stmt: Stmt) throws {
        try stmt.accept(visitor: self)
    }
    
    func evaluate(_ expr: Expr) throws -> Any? {
        return try expr.accept(visitor: self)
    }
    
    func typecheckDeclaration(token: Token, declarationType: NicType, initializedType: NicType) throws {
        switch (declarationType, initializedType) {
        case (.integer, .integer),
             (.string, .string),
             (.double, .double),
             (.boolean, .boolean):
            break
        default:
            Nic.error(at: token.line, message: "Declaration initialized with a value of type '\(initializedType)' but expected a value of type '\(declarationType)'")
            throw NicError.declarationTypeMismatch(token: token)
        }
    }
    
    func evaluateOperation(operationType: TokenType, with lhs: Any?, rhs: Any?) -> Any? {
        switch (lhs, rhs) {
        case (let lhsInt as Int, let rhsInt as Int):
            return evaluateIntegerOperation(lhs: lhsInt, rhs: rhsInt, operation: operationType)
        case (let lhsDouble as Double, let rhsDouble as Double):
            return evaluateDoubleOperation(lhs: lhsDouble, rhs: rhsDouble, operation: operationType)
        case (let lhsString as String, let rhsString as String):
            return lhsString + rhsString
        default:
            return nil
        }
    }
    
    func evaluateIntegerOperation(lhs: Int, rhs: Int, operation: TokenType) -> Int? {
        switch operation {
        case .plus: return lhs + rhs
        case .minus: return lhs - rhs
        case .star: return lhs * rhs
        case .slash: return lhs / rhs
        default: return nil
        }
    }
    
    func evaluateDoubleOperation(lhs: Double, rhs: Double, operation: TokenType) -> Double? {
        switch operation {
        case .plus: return lhs + rhs
        case .minus: return lhs - rhs
        case .star: return lhs * rhs
        case .slash: return lhs / rhs
        default: return nil
        }
    }
    
    func validOperands(operand1: Any?, operand2: Any?, for operationType: TokenType) -> Bool {
        let lhsType = operand1.nicType()
        let rhsType = operand2.nicType()
        switch (lhsType, operationType, rhsType) {
        case (.integer?, .plus, .integer?),
             (.integer?, .minus, .integer?),
             (.integer?, .star, .integer?),
             (.integer?, .slash, .integer?),
             (.double?, .plus, .double?),
             (.double?, .minus, .double?),
             (.double?, .star, .double?),
             (.double?, .slash, .double?),
             (.string?, .plus, .string?):
            return true
        default:
            return false
        }
    }
}
