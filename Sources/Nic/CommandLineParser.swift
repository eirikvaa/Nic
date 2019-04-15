//
//  CommandLineArgumentParser.swift
//  Nic
//
//  Created by Eirik Vale Aase on 30.05.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation

struct CommandLineParser {
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
        let tokens: [Token]
        
        print("Source:")
        print(source)
        
        do {
             tokens = try scanner.scanTokens()
        } catch {
            print("Program ended unexpectedly with the following error: \(error)")
            return
        }
        
        print("Tokens:")
        print(tokens)
        
        var parser = Parser(tokens: tokens)
        var statements: [Stmt] = []
        
        do {
            statements = try parser.parseTokens()
        } catch let error as NicParserError {
            switch error {
            case .unexpectedToken(let token):
                print("Unexpected token: \(token.lexeme)")
            case .missingRValue:
                print("Missing a value after '=' in variable declaration.")
            case .illegalRightValue(let token):
                print("Expected a valid value after '=' in variable declaration, but found a \(token) instead.")
            case .unterminatedStatement(let line):
                print("Unterminated statement on line \(line).")
            }
        } catch {
            print("Program ended unexpectedly with the following error: \(error)")
        }
        
        let resolver = Resolver()
        let typeChecker = TypeChecker()
        
        do {
            print("\nResolving:")
            try resolver.resolve(statements)
            
            let codeGenerator = IRGenerator(environment: resolver.environment)
            
            print("\nType checking:")
            try typeChecker.typecheck(statements)
            
            print("\nCode generation")
            try codeGenerator.generate(statements)
            codeGenerator.builder.module.dump()
        } catch {
            print(error.localizedDescription)
        }
    }
}
