//
//  NicTypeCheckerTests.swift
//  NicTests
//
//  Created by Eirik Vale Aase on 17/04/2019.
//

import XCTest

@testable import Nic

class NicTypeCheckerTests: XCTestCase {

    func testCorrectTypeAnnotation() {
        let source = "var test: Bool = false;";
        var scanner = Scanner(source: source)
        let tokens = try? scanner.scanTokens()
        
        var parser = Parser(tokens: tokens ?? [])
        let statements = try? parser.parseTokens()
        
        let typeChecker = TypeChecker()
        XCTAssertNoThrow(try typeChecker.typecheck(statements ?? []))
    }
    
    func testIncorrectTypeAnnotation() {
        let source = "var test: Bool = 0;";
        var scanner = Scanner(source: source)
        let tokens = try? scanner.scanTokens()
        
        var parser = Parser(tokens: tokens ?? [])
        let statements = try? parser.parseTokens()
        
        let typeChecker = TypeChecker()
        XCTAssertThrowsError(try typeChecker.typecheck(statements ?? []), "Initializing a variable of another type than the type annotation indicates.")
    }

}
