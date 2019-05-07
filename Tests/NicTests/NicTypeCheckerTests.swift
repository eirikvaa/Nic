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
        let scanner = Scanner(source: source)
        let tokens = scanner.scan()
        
        let parser = Parser(tokens: tokens)
        let statements = parser.parse()
        
        let typeChecker = TypeChecker()
        XCTAssertNoThrow(try typeChecker.typecheck(statements))
    }

}
