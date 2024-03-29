//
//  TypeChecker.swift
//  Nic
//
//  Created by Eirik Vale Aase on 15/04/2019.
//

/// `TypeChecker` would traverse the tree and make sure that the type system is satisfied.
class TypeChecker {
    private let symbolTable = SymbolTable.shared
    func typecheck(_ statements: [Stmt]) throws {
        for stmt in statements {
            try stmt.accept(visitor: self)
        }
    }
}

extension TypeChecker: StmtVisitor {
    func visitIfStatement(_ stmt: Stmt.If) throws {
        let value = try evaluate(stmt.condition)

        guard let valueType = value.nicType() else {
            return
        }

        guard let condition = value as? Bool else {
            throw NicError.invalidConditionalExpressionType(line: stmt.condition.depth, type: valueType)
        }

        if condition {
            try typecheck(stmt.ifBranch)
        } else if let elseBranch = stmt.elseBranch {
            try typecheck(elseBranch)
        }
    }

    func visitExpressionStatement(_ stmt: Stmt.Expression) throws {
        let _ = try evaluate(stmt.expression)
    }

    func visitConstStmt(_ stmt: Stmt.Const) throws {
        let value = try evaluate(stmt.initializer)

        if let declarationType = stmt.type,
           let valueType = value.nicType()
        {
            try typecheckDeclaration(token: stmt.name, declarationType: declarationType, initializedType: valueType)
        }

        let newRecord = SymbolTableValue(value: value)
        symbolTable.set(newRecord: newRecord, token: stmt.name, distance: stmt.initializer.depth)
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

        var value = try evaluate(initializer)
        if let stmtType = stmt.type,
           let valueType = value.nicType()
        {
            // We'll coerce variable declarations that were type annotated with double but initialized
            // with an integer.
            if stmtType == .double, valueType == .integer {
                value = Double((value as? Int) ?? 0)
            } else {
                try typecheckDeclaration(token: stmt.name, declarationType: stmtType, initializedType: valueType)
            }
        }

        let newRecord = SymbolTableValue(value: value, isMutable: true)
        symbolTable.set(newRecord: newRecord, token: stmt.name, distance: stmt.initializer?.depth ?? 0)
    }

    func visitPrintStmt(_ stmt: Stmt.Print) throws {
        guard let value = stmt.value else {
            return
        }

        try print(value.accept(visitor: self) ?? "No value")
    }
}

extension TypeChecker: ExprVisitor {
    func visitLogicalExpr(expr: Expr.Logical) throws -> Any? {
        let lhs = try evaluate(expr.left)
        let op = expr.op.type
        let rhs = try evaluate(expr.right)

        guard let lhsType = lhs.nicType(), let rhsType = rhs.nicType() else {
            return nil
        }

        guard lhsType == .boolean, rhsType == .boolean else {
            throw NicError.invalidOperands(line: expr.op.line, lhsType: lhsType, rhsType: rhsType, operationType: op)
        }

        guard let lhsValue = lhs as? Bool, let rhsValue = rhs as? Bool else {
            return nil
        }

        return evaluateBinaryLogicalOperation(lhs: lhsValue, rhs: rhsValue, operation: op)
    }

    func visitAssignExpr(expr: Expr.Assign) throws -> Any? {
        let assignmentValue = try evaluate(expr.value)
        let existingRecord = try symbolTable.get(name: expr.name, at: expr.depth)

        guard let canBeMutated = existingRecord?.isMutable, canBeMutated else {
            throw NicError.attemptToMutateConstant(token: expr.name)
        }

        guard let typeOfAssignment = assignmentValue.nicType(),
              let typeOfReceiver = existingRecord?.value.nicType()
        else {
            return nil
        }

        guard typeOfAssignment == typeOfReceiver else {
            throw NicError.invalidAssignment(type: typeOfAssignment, token: expr.name)
        }

        symbolTable.set(element: assignmentValue, at: \.value, to: expr.name, at: expr.depth)

        return assignmentValue
    }

    func visitGroupExpr(expr: Expr.Group) throws -> Any? {
        return try evaluate(expr.value)
    }

    func visitUnaryExpr(expr: Expr.Unary) throws -> Any? {
        let test = try evaluate(expr.value)

        switch expr.operator.type {
        case .bang:
            let boolean = test as? Bool ?? false
            return !boolean
        case .minus:
            if let number = test as? Int {
                return -number
            } else if let double = test as? Double {
                return -double
            }
        default:
            break
        }

        return nil
    }

    func visitLiteralExpr(expr: Expr.Literal) throws -> Any? {
        return expr.value
    }

    func visitBinaryExpr(expr: Expr.Binary) throws -> Any? {
        let lhs = try evaluate(expr.leftValue)
        let rhs = try evaluate(expr.rightValue)

        guard let lhsType = lhs.nicType(),
              let rhsType = rhs.nicType()
        else {
            return nil
        }
        let operationType = expr.operator.type

        if !validOperands(operand1: lhs, operand2: rhs, for: operationType) {
            throw NicError.invalidOperands(line: expr.operator.line, lhsType: lhsType, rhsType: rhsType, operationType: operationType)
        }

        let comparisonTokenTypes: [TokenType] = [
            .bang_equal, .equal_equal, .greater_equal, .less_equal, .greater, .less,
        ]

        if comparisonTokenTypes.contains(operationType) {
            if let intA = lhs as? Int, let intB = rhs as? Int {
                return evaluateComparisonOperation(lhs: intA, rhs: intB, operation: operationType)
            } else {
                return nil
            }
        } else {
            return evaluateOperation(operationType: operationType, with: lhs, rhs: rhs)
        }
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
            throw NicError.declarationTypeMismatch(token: token)
        }
    }

    func evaluateOperation(operationType: TokenType, with lhs: Any?, rhs: Any?) -> Any? {
        return switch (lhs, rhs) {
        case let (lhsInt as Int, rhsInt as Int):
            evaluateIntegerOperation(lhs: lhsInt, rhs: rhsInt, operation: operationType)
        case let (lhsDouble as Double, rhsDouble as Double):
            evaluateDoubleOperation(lhs: lhsDouble, rhs: rhsDouble, operation: operationType)
        case let (lhsDouble as Double, rhsInt as Int):
            evaluateDoubleIntegerOperation(lhs: lhsDouble, rhs: rhsInt, operation: operationType)
        case let (lhsInt as Int, rhsDouble as Double):
            evaluateIntegerDoubleOperation(lhs: lhsInt, rhs: rhsDouble, operation: operationType)
        case let (lhsString as String, rhsString as String):
            lhsString + rhsString
        default:
            nil
        }
    }

    func evaluateComparisonOperation(lhs: Int, rhs: Int, operation: TokenType) -> Bool? {
        return switch operation {
        case .equal_equal: lhs == rhs
        case .bang_equal: lhs != rhs
        case .greater: lhs > rhs
        case .less: lhs < rhs
        case .greater_equal: lhs >= rhs
        case .less_equal: lhs <= rhs
        default: nil
        }
    }

    func evaluateBinaryLogicalOperation(lhs: Bool, rhs: Bool, operation: TokenType) -> Bool? {
        return switch operation {
        case .or: lhs || rhs
        case .and: lhs && rhs
        default: nil
        }
    }

    func evaluateIntegerOperation(lhs: Int, rhs: Int, operation: TokenType) -> Int? {
        return switch operation {
        case .plus: lhs + rhs
        case .minus: lhs - rhs
        case .star: lhs * rhs
        case .slash: lhs / rhs
        default: nil
        }
    }

    func evaluateDoubleOperation(lhs: Double, rhs: Double, operation: TokenType) -> Double? {
        return switch operation {
        case .plus: lhs + rhs
        case .minus: lhs - rhs
        case .star: lhs * rhs
        case .slash: lhs / rhs
        default: nil
        }
    }

    func evaluateDoubleIntegerOperation(lhs: Double, rhs: Int, operation: TokenType) -> Double? {
        return switch operation {
        case .plus: lhs + Double(rhs)
        case .minus: lhs - Double(rhs)
        case .star: lhs * Double(rhs)
        case .slash: lhs / Double(rhs)
        default: nil
        }
    }

    func evaluateIntegerDoubleOperation(lhs: Int, rhs: Double, operation: TokenType) -> Double? {
        return switch operation {
        case .plus: Double(lhs) + rhs
        case .minus: Double(lhs) - rhs
        case .star: Double(lhs) * rhs
        case .slash: Double(lhs) / rhs
        default: nil
        }
    }

    func validOperands(operand1: Any?, operand2: Any?, for operationType: TokenType) -> Bool {
        let lhsType = operand1.nicType()
        let rhsType = operand2.nicType()

        switch (lhsType, rhsType) {
        case (.integer?, .integer?),
             (.double?, .double?),
             (.integer?, .double?),
             (.double?, .integer?):
            let validTypes: [TokenType] = [
                .plus, .minus, .star, .slash,
                .equal_equal, .less_equal, .greater_equal, .bang_equal,
                .less, .greater,
            ]
            return validTypes.contains(operationType)
        case (.string?, .string?):
            return operationType == .plus
        default:
            return false
        }
    }
}
