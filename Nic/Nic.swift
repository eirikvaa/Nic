//
//  Nic.swift
//  Nic
//
//  Created by Eirik Vale Aase on 30.05.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation
//import LLVM

class Nic {
    static var hadError = false
    
    static func parse(_ arguments: [String]) {
        switch arguments.count {
        case 0:
            print("Please provide the path to a file.")
        case 2:
            run(path: arguments[1])
        default:
            break
        }
    }

    static func run(path: String) {
        guard let data = FileManager.default.contents(atPath: path) else { return }
        guard let source = String(data: data, encoding: .utf8) else { return }
        let scanner = Scanner(source: source)
        //let codeGenerator = CodeGenerator()
        let resolver = Resolver()
        let typeChecker = TypeChecker()
        
        let tokens = scanner.scan()
        let parser = Parser(tokens: tokens)
        let statements = parser.parse()
        
        if hadError {
            return
        }
        
        do {
            try resolver.resolve(statements)
            try typeChecker.typecheck(statements)
            //try codeGenerator.generate(statements)
            //try codeGenerator.verifyLLVMIR()
            //codeGenerator.dumpLLVMIR()
            //codeGenerator.createLLVMIRFile(fileName: "test")
        } catch {
            handleError(error)
        }
    }
    
    private static func handleError(_ error: Error) {
        switch error {
        case let runtimeError as NicRuntimeError:
            handleRuntimeError(runtimeError)
        case let error as NicError:
            handleNicError(error)
        //case let moduleError as LLVM.ModuleError:
        //    print(moduleError)
        default:
            print(error.localizedDescription)
        }
    }
    
    private static func handleRuntimeError(_ error: NicRuntimeError) {
        switch error {
        case .undefinedVariable(let name):
            self.error(token: name, message: "Undefined variable '\(name.lexeme)'")
        case .illegalConstantMutation(let name):
            self.error(token: name, message: "Tried to mutate constant '\(name.lexeme)'")
        }
    }
    
    private static func handleNicError(_ error: NicError) {
        switch error {
        case .declarationTypeMismatch(let token):
            self.error(token: token, message: "Mismatch between type of initializer and type annotation in declaration.")
        case .invalidAssignment(let type, let token):
            self.error(token: token, message: "Invalid assignment value of type '\(type)' for token '\(token.lexeme)'")
        case .expectExpression(let token):
            self.error(token: token, message: "Expected expression for token '\(token.lexeme)'")
        case .unexpectedToken(let token):
            self.error(token: token, message: "Unexpected token '\(token.lexeme)")
        case .invalidOperands(let line, let lhsType, let rhsType, let operation):
            self.error(line: line, message: "Invalid operands of type '\(lhsType)' and '\(rhsType)' for '\(operation)' operation.")
        case .invalidConditionalExpressionType(let line, let type):
            self.error(line: line, message: "Can't use an expression of type \(type) as an if statement condition.")
        }
    }
    
    static func error(token: Token, message: String) {
        hadError = true
        print("[Line \(token.line)] \(message)")
    }
    
    static func error(line: Int, message: String) {
        hadError = true
        print("[Line \(line) \(message)")
    }
}
