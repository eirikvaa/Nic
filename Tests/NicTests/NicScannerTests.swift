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

    // MARK: Empty source
    func testEmptySourceShouldGiveEmptyTokenList() {
        let source = ""
        var scanner = Scanner(source: source)
        
        let expectedTokenTypes: [TokenType] = [.eof]
        let tokenTypes = scanner.scanTokens().map { $0.type }
        
        XCTAssertEqual(expectedTokenTypes, tokenTypes, "An empty source should give an empty token list.")
    }
    
    // MARK: Numbers
    func testSingleDigitNumber() {
        let source = "1;"
        var scanner = Scanner(source: source)
        
        let expectedTokenTypes: [TokenType] = [.integer, .semicolon, .eof]
        let tokenTypes = scanner.scanTokens().map { $0.type }
        
        XCTAssertEqual(expectedTokenTypes, tokenTypes, "A source consisting of a single number should return a token list with a single token of type number.")
    }
    
    func testSourceWithSingleDigitNumberEndingInNewline() {
        let source = "1;\n"
        var scanner = Scanner(source: source)
        
        let expectedTokenTypes: [TokenType] = [.integer, .semicolon, .eof]
        let tokenTypes = scanner.scanTokens().map { $0.type }
        
        XCTAssertEqual(expectedTokenTypes, tokenTypes, "A source consisting of a single number should return a token list with a single token of type number.")
    }
    
    func testSingleMultipleDigitNumber() {
        let source = "123;"
        var scanner = Scanner(source: source)
        
        let expectedTokenTypes: [TokenType] = [.integer, .semicolon, .eof]
        let tokenTypes = scanner.scanTokens().map { $0.type }
        
        XCTAssertEqual(expectedTokenTypes, tokenTypes, "A source consisting of a single multi-digit number should resolve to a single token.")
    }
    
    func testMultipleMultiDigitNumbers() {
        let source = "123; 123;"
        var scanner = Scanner(source: source)
        
        let expectedTokenTypes: [TokenType] = [.integer, .semicolon, .integer, .semicolon, .eof]
        
        let tokenTypes = scanner.scanTokens().map { $0.type }
        
        XCTAssertEqual(expectedTokenTypes, tokenTypes, "A source consisting of two multi-digit numbers should resolve to two tokens.")
    }
    
    // MARK: Comments
    func testComment() {
        let source = "//"
        var scanner = Scanner(source: source)
        
        let expectedTokenTypes: [TokenType] = [.eof]
        let tokenTypes = scanner.scanTokens().map { $0.type }
        
        XCTAssertEqual(expectedTokenTypes, tokenTypes, "A source consisting solely of two forward slashes should be interpreted as as comment and return an empty list of tokens.")
    }
    
    func testCommentThatIgnoresASingleToken() {
        let source = "//123"
        var scanner = Scanner(source: source)
        
        let expectedTokenTypes: [TokenType] = [.eof]
        let tokenTypes = scanner.scanTokens().map { $0.type }
        
        XCTAssertEqual(expectedTokenTypes, tokenTypes, "A source consisting solely of two forward slashes should be interpreted as as comment and return an empty list of tokens.")
    }
    
    func testCommentBetweenTwoTokensShouldReturnASingleToken() {
        let source = "123;//123"
        var scanner = Scanner(source: source)
        
        let expectedTokenTypes: [TokenType] = [.integer, .semicolon, .eof]
        let tokenTypes = scanner.scanTokens().map { $0.type }
        
        XCTAssertEqual(expectedTokenTypes, tokenTypes, "A source consisting solely of two forward slashes should be interpreted as as comment and return an empty list of tokens.")
    }
    
    func testMultiLineCommentHidesSecondTokenShouldReturnOneToken() {
        let source = "123;/*123*/"
        var scanner = Scanner(source: source)
        
        let expectedTokenTypes: [TokenType] = [.integer, .semicolon, .eof]
        let tokenTypes = scanner.scanTokens().map { $0.type }
        
        XCTAssertEqual(expectedTokenTypes, tokenTypes, "A source consisting solely of a multi-digit number and a multi-line comment consisting of number inside should return a single number token.")
    }
    
    // MARK: Strings
    func testSingleString() {
        let source = #""Hei på deg";"#
        var scanner = Scanner(source: source)
        
        let expectedTokenTypes: [TokenType] = [.string, .semicolon, .eof]
        let tokenTypes = scanner.scanTokens().map { $0.type }
        
        XCTAssertEqual(expectedTokenTypes, tokenTypes, "A source consisting of a string should return a single token of that string.")
    }
    
    // MARK: Mathematical expressions
    func testNumberPlusNumber() {
        let source = "123+123;"
        var scanner = Scanner(source: source)
        
        let expectedTokenTypes: [TokenType] = [.integer, .plus, .integer, .semicolon, .eof]
        let tokenTypes = scanner.scanTokens().map { $0.type }
        
        XCTAssertEqual(expectedTokenTypes, tokenTypes, "A number, an operator and a number should result in three tokens.")
    }
    
    func testNumberDivideNumber() {
        let source = "123/123;"
        var scanner = Scanner(source: source)
        
        let expectedTokenTypes: [TokenType] = [.integer, .slash, .integer, .semicolon, .eof]
        let tokenTypes = scanner.scanTokens().map { $0.type }
        
        XCTAssertEqual(expectedTokenTypes, tokenTypes, "A number, an operator and a number should result in three tokens (including EOF).")
    }
    
    // MARK: Print
    func testPrintStatementWithValue() {
        let source = #"print "Hello, world!";"#
        var scanner = Scanner(source: source)
        
        let expectedTokenTypes: [TokenType] = [.print, .string, .semicolon, .eof]
        let tokenTypes = scanner.scanTokens().map { $0.type }
        
        XCTAssertEqual(expectedTokenTypes, tokenTypes, "Print statement that prints a string was not tokenized correctly.")
    }
    
    func testPrintStatementWithBinaryNumberLiteralExpression() {
        let source = "print 1 + 1;"
        var scanner = Scanner(source: source)
        
        let expectedTokenTypes: [TokenType] = [.print, .integer, .plus, .integer, .semicolon, .eof]
        let tokenTypes = scanner.scanTokens().map { $0.type }
        
        XCTAssertEqual(expectedTokenTypes, tokenTypes, "Print statements that prints the result of adding two literal numbers not tokenized correctly.")
    }
    
    // MARK: Variable declarations
    func testVariableDeclarationWithInitialization() {
        let source = "var number = 3;"
        var scanner = Scanner(source: source)
        
        let expectedTokenTypes: [TokenType] = [.var, .identifier, .equal, .integer, .semicolon, .eof]
        let tokenTypes = scanner.scanTokens().map { $0.type }
        
        XCTAssertEqual(expectedTokenTypes, tokenTypes, "A var keyword, an identifier, an equals sign and a number should result in four tokens (including EOF).")
    }
    
    func testBooleanVariableDeclaration() {
        let source = "var test = true;"
        var scanner = Scanner(source: source)
        
        let expectedTokenTypes: [TokenType] = [.var, .identifier, .equal, .true, .semicolon, .eof]
        let tokenTypes = scanner.scanTokens().map { $0.type }
        
        XCTAssertEqual(expectedTokenTypes, tokenTypes, "Tokenizing of a boolean variable declaration failed.")
    }
    
    func testBooleanVariableDeclarationWithTypeAnnotation() {
        let source = "var test: Bool = false;";
        var scanner = Scanner(source: source)
        
        let expectedTokenTypes: [TokenType] = [.var, .identifier, .colon, .identifier, .equal, .false, .semicolon, .eof]
        let tokenTypes = scanner.scanTokens().map { $0.type }
        XCTAssertEqual(expectedTokenTypes, tokenTypes, "Tokenizing of a boolean variable declaration failed.")
    }
    
    func testBinayNumberLiteralExpression() {
        let source = "var test = 1 + 1;"
        var scanner = Scanner(source: source)
        
        let expectedTokenTypes: [TokenType] = [.var, .identifier, .equal, .integer, .plus, .integer, .semicolon, .eof]
        let tokenTypes = scanner.scanTokens().map { $0.type }
        
        XCTAssertEqual(expectedTokenTypes, tokenTypes, "Variable declaration for binary expression with number literal operands failed.")
    }

}
