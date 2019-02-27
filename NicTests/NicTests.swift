//
//  NicTests.swift
//  NicTests
//
//  Created by Eirik Vale Aase on 27/02/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

import XCTest

@testable import Nic

class NicTests: XCTestCase {

    func testEmptySourceShouldGiveEmptyTokenList() {
        let source = ""
        var scanner = Scanner(source: source)
        let tokens = scanner.scan()
        
        XCTAssertEqual(tokens, [], "An empty source should give an empty token list.")
    }
    
    func testSingleDigitNumber() {
        let source = "1"
        var scanner = Scanner(source: source)
        
        let expectedToken = Token(type: .number, lexeme: "1", value: 1)
        let tokens = scanner.scan()
        
        XCTAssertTrue(tokens.count == 1, "A source consisting of a single number should return a token list with a single token of type number.")
        XCTAssertEqual(expectedToken, tokens.first)
    }
    
    func testSourceWithSingleDigitNumberEndingInNewline() {
        let source = "1\n"
        var scanner = Scanner(source: source)
        
        let expectedToken = Token(type: .number, lexeme: "1", value: 1)
        let tokens = scanner.scan()
        
        XCTAssertTrue(tokens.count == 1, "A source consisting of a single number should return a token list with a single token of type number.")
        XCTAssertEqual(expectedToken, tokens.first)
    }
    
    func testSingleMultipleDigitNumber() {
        let source = "123"
        var scanner = Scanner(source: source)
        
        let expectedToken = Token(type: .number, lexeme: "123", value: 123)
        let tokens = scanner.scan()
        
        XCTAssertEqual(expectedToken, tokens.first, "A source consisting of a single multi-digit number should resolve to a single token.")
    }
    
    func testMultipleMultiDigitNumbers() {
        let source = "123 123"
        var scanner = Scanner(source: source)
        
        let expectedTokens = [
            Token(type: .number, lexeme: "123", value: 123),
            Token(type: .number, lexeme: "123", value: 123)
        ]
        
        let tokens = scanner.scan()
        
        XCTAssertEqual(expectedTokens, tokens, "A source consisting of two multi-digit numbers should resolve to two tokens.")
    }

}
