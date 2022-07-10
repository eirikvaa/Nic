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
        XCTAssertNoThrow(try typeCheckSource(source))
    }
    
    func testIncorrectTypeAnnotation() {
        let source = #"var test: Bool = 1;"#
        XCTAssertThrowsError(try typeCheckSource(source), "Type of initialization expression does not correspond with type annotation.")
    }
    
    func testCorrectBinaryOperationOperands() {
        let source = #"var test = 1 + 1;"#
        XCTAssertNoThrow(try typeCheckSource(source))
    }
    
    func testInvalidBinaryOperationOperands() {
        let source = #"var test = 1 + true;"#
        XCTAssertThrowsError(try typeCheckSource(source), "Cannot add an integer and a boolean value")
    }
    
    func testValidIfStatementExpression() {
        let source = #"var boolean = true; if boolean {}"#
        XCTAssertNoThrow(try typeCheckSource(source), "Only expressions evaluating to true can appear as an if statement condition.")
    }

    func testValidIfStatementExpressionFalseCondition() {
        let source = #"var boolean = false; if boolean {}"#
        XCTAssertNoThrow(try typeCheckSource(source), "Only expressions evaluating to true can appear as an if statement condition.")
    }
    
    func testInvalidIfStatementExpression() {
        let source = #"var boolean = 1; if boolean {}"#
        XCTAssertThrowsError(try typeCheckSource(source), "Only expressions evaluating to true can appear as an if statement condition.")
    }

    func testCannotMutateConst() {
        let source = "const a = 3; a = 4;";
        XCTAssertThrowsError(try typeCheckSource(source), "Constants cannot be mutated after declaration.")
    }

}

extension NicTypeCheckerTests {
    func typeCheckSource(_ source: String) throws {
        let scanner = Scanner(source: source)
        let tokens = scanner.scan()
        
        let parser = Parser(tokens: tokens)
        let statements = parser.parse()
        
        let typeChecker = TypeChecker()
        try typeChecker.typecheck(statements)
    }
}
