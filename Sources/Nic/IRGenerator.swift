//
//  IRGenerator.swift
//  Nic
//
//  Created by Eirik Vale Aase on 23/03/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

import Foundation
import LLVM

struct IRGenerator {
    let module: Module
    let builder: IRBuilder
    let mainFunction: Function
    
    init() {
        module = Module(name: "main")
        builder = IRBuilder(module: module)
        
        let mainType = FunctionType(argTypes: [], returnType: VoidType())
        mainFunction = builder.addFunction("main", type: mainType)
        
        let entry = mainFunction.appendBasicBlock(named: "entry")
        builder.positionAtEnd(of: entry)
    }
    
    func addGlobalVariable(declaration: Stmt.Var) {
        switch declaration.initializer {
        case let literal as Expr.Literal:
            switch literal.value {
            case let number as Int:
                let irValue = IntType.int64.constant(number)
                let _ = builder.addGlobal(declaration.name.lexeme, initializer: irValue)
            case let string as String:
                let _ = builder.addGlobalString(name: declaration.name.lexeme, value: string)
            default:
                break
            }
        case let binary as Expr.Binary:
            switch (binary.leftValue, binary.operator, binary.rightValue) {
            case (let lhs as Expr.Literal, _, let rhs as Expr.Literal):
                switch (lhs.value, binary.operator.lexeme, rhs.value) {
                case (let lhsNumber as Int, "+", let rhsNumber as Int):
                    let add = builder.buildAdd(lhsNumber, rhsNumber)
                    let _ = builder.addGlobal(declaration.name.lexeme, initializer: add)
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
}
