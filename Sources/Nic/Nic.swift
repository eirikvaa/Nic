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
        
        let tokens = scanner.scanTokens()
        print(tokens)
        
        if hadError {
            return
        }
        
        var parser = Parser(tokens: tokens)
        let statements = parser.parseTokens()
        
        if hadError {
            return
        }
        
        let irGenerator = IRGenerator()
        let resolver = Resolver(irGenerator: irGenerator)
        let typeChecker = TypeChecker()
        
        do {
            try resolver.resolve(statements)
            
            try typeChecker.typecheck(statements)
            
            if hadError {
                return
            }
            
            try irGenerator.generate(statements)
            irGenerator.builder.module.dump()
        } catch {
            return
        }
    }
    
    static func error(at line: Int, message: String) {
        hadError = true
        print("[Line \(line + 1)] \(message)")
    }
}
