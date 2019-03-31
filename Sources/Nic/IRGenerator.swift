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
        default:
            break
        }
        
        module.dump()
    }
}
