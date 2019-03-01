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
        let tokens = try? scanner.scan()
        
        XCTAssertEqual(tokens, [], "An empty source should give an empty token list.")
    }
    
    func testSingleDigitNumber() {
        let source = "1"
        var scanner = Scanner(source: source)
        
        let expectedToken = Token(type: .number(value: 1), lexeme: "1")
        let tokens = try? scanner.scan()
        
        XCTAssertTrue(tokens?.count == 1, "A source consisting of a single number should return a token list with a single token of type number.")
        XCTAssertEqual(expectedToken, tokens?.first)
    }
    
    func testSourceWithSingleDigitNumberEndingInNewline() {
        let source = "1\n"
        var scanner = Scanner(source: source)
        
        let expectedToken = Token(type: .number(value: 1), lexeme: "1")
        let tokens = try? scanner.scan()
        
        XCTAssertTrue(tokens?.count == 1, "A source consisting of a single number should return a token list with a single token of type number.")
        XCTAssertEqual(expectedToken, tokens?.first)
    }
    
    func testSingleMultipleDigitNumber() {
        let source = "123"
        var scanner = Scanner(source: source)
        
        let expectedToken = Token(type: .number(value: 123), lexeme: "123")
        let tokens = try? scanner.scan()
        
        XCTAssertEqual(expectedToken, tokens?.first, "A source consisting of a single multi-digit number should resolve to a single token.")
    }
    
    func testMultipleMultiDigitNumbers() {
        let source = "123 123"
        var scanner = Scanner(source: source)
        
        let expectedTokens = [
            Token(type: .number(value: 123), lexeme: "123"),
            Token(type: .number(value: 123), lexeme: "123")
        ]
        
        let tokens = try? scanner.scan()
        
        XCTAssertEqual(expectedTokens, tokens, "A source consisting of two multi-digit numbers should resolve to two tokens.")
    }
    
    func testSingleString() {
        let source = "\"Hei på deg\""
        var scanner = Scanner(source: source)
        
        let expectedToken = [Token(type: .string(characters: "Hei på deg"), lexeme: "Hei på deg")]
        let tokens = try? scanner.scan()
        
        XCTAssertEqual(expectedToken, tokens, "A source consisting of a string should return a single token of that string.")
    }
    
    func testComment() {
        let source = "//"
        var scanner = Scanner(source: source)
        
        let expectedToken: [Token] = []
        let tokens = try? scanner.scan()
        
        XCTAssertEqual(expectedToken, tokens, "A source consisting solely of two forward slashes should be interpreted as as comment and return an empty list of tokens.")
    }
    
    func testCommentThatIgnoresASingleToken() {
        let source = "//123"
        var scanner = Scanner(source: source)
        
        let expectedToken: [Token] = []
        let tokens = try? scanner.scan()
        
        XCTAssertEqual(expectedToken, tokens, "A source consisting solely of two forward slashes should be interpreted as as comment and return an empty list of tokens.")
    }
    
    func testCommentBetweenTwoTokensShouldReturnASingleToken() {
        let source = "123//123"
        var scanner = Scanner(source: source)
        
        let expectedToken: [Token] = [
            Token.init(type: .number(value: 123), lexeme: "123")
        ]
        let tokens = try? scanner.scan()
        
        XCTAssertEqual(expectedToken, tokens, "A source consisting solely of two forward slashes should be interpreted as as comment and return an empty list of tokens.")
    }
    
    func testMultiLineCommentHidesSecondTokenShouldReturnOneToken() {
        let source = "123/*123*/"
        var scanner = Scanner(source: source)
        
        let expectedToken: [Token] = [
            Token.init(type: .number(value: 123), lexeme: "123")
        ]
        let tokens = try? scanner.scan()
        
        XCTAssertEqual(expectedToken, tokens, "A source consisting solely of a multi-digit number and a multi-line comment consisting of number inside should return a single number token.")
    }
    
    func testUnterminatedStringLiteral() {
        let source = "\"Hei"
        var scanner = Scanner(source: source)
        
        XCTAssertThrowsError(try scanner.scan(), "Unterminated string literal should result in a crash")
    }
    
    func testUnterminatedMultiLineComment() {
        let source = "/* Hei"
        var scanner = Scanner(source: source)
        
        XCTAssertThrowsError(try scanner.scan(), "Unterminated multi-line comment should result in a crash")
    }
    
    func testNumberOperatorNumber() {
        let source = "123+123"
        var scanner = Scanner(source: source)
        
        let expectedTokens = [
            Token(type: .number(value: 123), lexeme: "123"),
            Token(type: .operator(operator: "+"), lexeme: "+"),
            Token(type: .number(value: 123), lexeme: "123")
        ]
        
        let tokens = try? scanner.scan()
        XCTAssertEqual(expectedTokens, tokens, "A number, an operator and a number should result in three tokens.")
    }

}
