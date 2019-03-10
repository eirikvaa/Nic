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
        let expectedTokens: [Token] = [
            Token(type: .eof, lexeme: "EOF", literal: nil, line: 0)
        ]
        let tokens = try? scanner.scanTokens()
        
        XCTAssertEqual(expectedTokens, tokens, "An empty source should give an empty token list.")
    }
    
    func testSingleDigitNumber() {
        let source = "1;"
        var scanner = Scanner(source: source)
        
        let expectedTokens: [Token] = [
            Token(type: .number, lexeme: "1", literal: 1, line: 0),
            Token(type: .semicolon, lexeme: ";", literal: nil, line: 0),
            Token(type: .eof, lexeme: "EOF", literal: nil, line: 0)
        ]
        let tokens = try? scanner.scanTokens()
        
        XCTAssertEqual(expectedTokens, tokens, "A source consisting of a single number should return a token list with a single token of type number.")
    }
    
    func testSourceWithSingleDigitNumberEndingInNewline() {
        let source = "1;\n"
        var scanner = Scanner(source: source)
        
        let expectedTokens: [Token] = [
            Token(type: .number, lexeme: "1", literal: 1, line: 0),
            Token(type: .semicolon, lexeme: ";", literal: nil, line: 0),
            Token(type: .eof, lexeme: "EOF", literal: nil, line: 0)
        ]
        let tokens = try? scanner.scanTokens()
        
        XCTAssertEqual(expectedTokens, tokens, "A source consisting of a single number should return a token list with a single token of type number.")
    }
    
    func testSingleMultipleDigitNumber() {
        let source = "123;"
        var scanner = Scanner(source: source)
        
        let expectedTokens: [Token] = [
            Token(type: .number, lexeme: "123", literal: 123, line: 0),
            Token(type: .semicolon, lexeme: ";", literal: nil, line: 0),
            Token(type: .eof, lexeme: "EOF", literal: nil, line: 0)
        ]
        let tokens = try? scanner.scanTokens()
        
        XCTAssertEqual(expectedTokens, tokens, "A source consisting of a single multi-digit number should resolve to a single token.")
    }
    
    func testMultipleMultiDigitNumbers() {
        let source = "123; 123;"
        var scanner = Scanner(source: source)
        
        let expectedTokens = [
            Token(type: .number, lexeme: "123", literal: 123, line: 0),
            Token(type: .semicolon, lexeme: ";", literal: nil, line: 0),
            Token(type: .number, lexeme: "123", literal: 123, line: 0),
            Token(type: .semicolon, lexeme: ";", literal: nil, line: 0),
            Token(type: .eof, lexeme: "EOF", literal: nil, line: 0)
        ]
        
        let tokens = try? scanner.scanTokens()
        
        XCTAssertEqual(expectedTokens, tokens, "A source consisting of two multi-digit numbers should resolve to two tokens.")
    }
    
    func testSingleString() {
        let source = "\"Hei på deg\";"
        var scanner = Scanner(source: source)
        
        let expectedTokens = [
            Token(type: .string, lexeme: "Hei på deg", literal: "Hei på deg", line: 0),
            Token(type: .semicolon, lexeme: ";", literal: nil, line: 0),
            Token(type: .eof, lexeme: "EOF", literal: nil, line: 0)
        ]
        let tokens = try? scanner.scanTokens()
        
        XCTAssertEqual(expectedTokens, tokens, "A source consisting of a string should return a single token of that string.")
    }
    
    func testComment() {
        let source = "//"
        var scanner = Scanner(source: source)
        
        let expectedToken: [Token] = [
            Token(type: .eof, lexeme: "EOF", literal: nil, line: 0)
        ]
        let tokens = try? scanner.scanTokens()
        
        XCTAssertEqual(expectedToken, tokens, "A source consisting solely of two forward slashes should be interpreted as as comment and return an empty list of tokens.")
    }
    
    func testCommentThatIgnoresASingleToken() {
        let source = "//123"
        var scanner = Scanner(source: source)
        
        let expectedToken: [Token] = [
            Token(type: .eof, lexeme: "EOF", literal: nil, line: 0)
        ]
        let tokens = try? scanner.scanTokens()
        
        XCTAssertEqual(expectedToken, tokens, "A source consisting solely of two forward slashes should be interpreted as as comment and return an empty list of tokens.")
    }
    
    func testCommentBetweenTwoTokensShouldReturnASingleToken() {
        let source = "123;//123"
        var scanner = Scanner(source: source)
        
        let expectedToken: [Token] = [
            Token(type: .number, lexeme: "123", literal: 123, line: 0),
            Token(type: .semicolon, lexeme: ";", literal: nil, line: 0),
            Token(type: .eof, lexeme: "EOF", literal: nil, line: 0)
        ]
        let tokens = try? scanner.scanTokens()
        
        XCTAssertEqual(expectedToken, tokens, "A source consisting solely of two forward slashes should be interpreted as as comment and return an empty list of tokens.")
    }
    
    func testMultiLineCommentHidesSecondTokenShouldReturnOneToken() {
        let source = "123;/*123*/"
        var scanner = Scanner(source: source)
        
        let expectedToken: [Token] = [
            Token(type: .number, lexeme: "123", literal: 123, line: 0),
            Token(type: .semicolon, lexeme: ";", literal: nil, line: 0),
            Token(type: .eof, lexeme: "EOF", literal: nil, line: 0)
        ]
        let tokens = try? scanner.scanTokens()
        
        XCTAssertEqual(expectedToken, tokens, "A source consisting solely of a multi-digit number and a multi-line comment consisting of number inside should return a single number token.")
    }
    
    func testUnterminatedStringLiteral() {
        let source = "\"Hei"
        var scanner = Scanner(source: source)
        
        XCTAssertThrowsError(try scanner.scanTokens(), "Unterminated string literal should result in a crash")
    }
    
    func testUnterminatedMultiLineComment() {
        let source = "/* Hei"
        var scanner = Scanner(source: source)
        
        XCTAssertThrowsError(try scanner.scanTokens(), "Unterminated multi-line comment should result in a crash")
    }
    
    func testNumberPlusNumber() {
        let source = "123+123;"
        var scanner = Scanner(source: source)
        
        let expectedTokens: [Token] = [
            Token(type: .number, lexeme: "123", literal: 123, line: 0),
            Token(type: .plus, lexeme: "+", literal: nil, line: 0),
            Token(type: .number, lexeme: "123", literal: 123, line: 0),
            Token(type: .semicolon, lexeme: ";", literal: nil, line: 0),
            Token(type: .eof, lexeme: "EOF", literal: nil, line: 0)
        ]
        
        let tokens = try? scanner.scanTokens()
        XCTAssertEqual(expectedTokens, tokens, "A number, an operator and a number should result in three tokens.")
    }
    
    func testNumberDivideNumber() {
        let source = "123/123;"
        var scanner = Scanner(source: source)
        
        let expectedTokens: [Token] = [
            Token(type: .number, lexeme: "123", literal: 123, line: 0),
            Token(type: .slash, lexeme: "/", literal: nil, line: 0),
            Token(type: .number, lexeme: "123", literal: 123, line: 0),
            Token(type: .semicolon, lexeme: ";", literal: nil, line: 0),
            Token(type: .eof, lexeme: "EOF", literal: nil, line: 0)
        ]
        
        let tokens = try? scanner.scanTokens()
        XCTAssertEqual(expectedTokens, tokens, "A number, an operator and a number should result in three tokens.")
    }
    
    func testVariableDeclarationWithInitialization() {
        let source = "var number = 3;"
        var scanner = Scanner(source: source)
        
        let expectedTokens = [
            Token(type: .var, lexeme: "var", literal: nil, line: 0),
            Token(type: .identifier, lexeme: "number", literal: "number", line: 0),
            Token(type: .equal, lexeme: "=", literal: nil, line: 0),
            Token(type: .number, lexeme: "3", literal: 3, line: 0),
            Token(type: .semicolon, lexeme: ";", literal: nil, line: 0),
            Token(type: .eof, lexeme: "EOF", literal: nil, line: 0)
        ]
        
        let tokens = try? scanner.scanTokens()
        XCTAssertEqual(expectedTokens, tokens, "A var keyword, an equals sign and a number should result in three tokens.")
    }

}
