//
//  Nic.swift
//  Nic
//
//  Created by Eirik Vale Aase on 30.05.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation

struct Nic {
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
        var scanner = Scanner(source: source)
        
        let tokens = scanner.scan()
        
        if hadError {
            return
        }
        
        var parser = Parser(tokens: tokens)
        let statements = parser.parse()
        
        if hadError {
            return
        }
        
        let codeGenerator = CodeGenerator()
        let resolver = Resolver(codeGenerator: codeGenerator)
        let typeChecker = TypeChecker()
        
        do {
            try resolver.resolve(statements)
            try typeChecker.typecheck(statements)
            
            if hadError {
                return
            }
            
            try codeGenerator.generate(statements)
            codeGenerator.createLLVMIRFile(fileName: "test")
        } catch {
            handleError(error)
            return
        }
    }
    
    private static func handleError(_ error: Error) {
        switch error {
        case let runtimeError as NicRuntimeError:
            handleRuntimeError(runtimeError)
        default:
            print(error.localizedDescription)
        }
    }
    
    private static func handleRuntimeError(_ error: NicRuntimeError) {
        switch error {
        case .undefinedVariable(let name):
            print("[Line \(name.line + 1)] Undefined variable '\(name.lexeme)'")
        case .illegalConstantMutation(let name):
            print("[Line \(name.line + 1)] Tried to mutate constant '\(name.lexeme)'")
        }
    }
    
    static func error(at line: Int, message: String) {
        hadError = true
        print("[Line \(line + 1)] \(message)")
    }
}
