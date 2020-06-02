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
        let expectedTokenTypes: [TokenType] = [.eof]
        let result = scanSource(source: source, compareWithExpectedTokens: expectedTokenTypes)
        
        XCTAssertTrue(result, "An empty source should give an empty token list.")
    }
    
    // MARK: Numbers
    func testSingleDigitNumber() {
        let source = "1;"
        let expectedTokenTypes: [TokenType] = [.integer, .semicolon, .eof]
        let result = scanSource(source: source, compareWithExpectedTokens: expectedTokenTypes)
        
        XCTAssertTrue(result, "A source consisting of a single number should return a token list with a single token of type number.")
    }
    
    func testFloatingPointNumber() {
        let source = "1.0;";
        let expectedTokenTypes: [TokenType] = [.double, .semicolon, .eof]
        let result = scanSource(source: source, compareWithExpectedTokens: expectedTokenTypes)
        
        XCTAssertTrue(result, "A floating point number has not been parsed correctly.")
    }
    
    func testSourceWithSingleDigitNumberEndingInNewline() {
        let source = "1;\n"
        let expectedTokenTypes: [TokenType] = [.integer, .semicolon, .eof]
        let result = scanSource(source: source, compareWithExpectedTokens: expectedTokenTypes)
        
        XCTAssertTrue(result, "A source consisting of a single number should return a token list with a single token of type number.")
    }
    
    func testSingleMultipleDigitNumber() {
        let source = "123;"
        let expectedTokenTypes: [TokenType] = [.integer, .semicolon, .eof]
        let result = scanSource(source: source, compareWithExpectedTokens: expectedTokenTypes)
        
        XCTAssertTrue(result, "A source consisting of a single multi-digit number should resolve to a single token.")
    }
    
    func testMultipleMultiDigitNumbers() {
        let source = "123; 123;"
        let expectedTokenTypes: [TokenType] = [.integer, .semicolon, .integer, .semicolon, .eof]
        let result = scanSource(source: source, compareWithExpectedTokens: expectedTokenTypes)
        
        XCTAssertTrue(result, "A source consisting of two multi-digit numbers should resolve to two tokens.")
    }
    
    // MARK: Comments
    func testComment() {
        let source = "//"
        let expectedTokenTypes: [TokenType] = [.eof]
        let result = scanSource(source: source, compareWithExpectedTokens: expectedTokenTypes)
        
        XCTAssertTrue(result, "A source consisting solely of two forward slashes should be interpreted as as comment and return an empty list of tokens.")
    }
    
    func testCommentThatIgnoresASingleToken() {
        let source = "//123"
        let expectedTokenTypes: [TokenType] = [.eof]
        let result = scanSource(source: source, compareWithExpectedTokens: expectedTokenTypes)
        
        XCTAssertTrue(result, "A source consisting solely of two forward slashes should be interpreted as as comment and return an empty list of tokens.")
    }
    
    func testCommentBetweenTwoTokensShouldReturnASingleToken() {
        let source = "123;//123"
        let expectedTokenTypes: [TokenType] = [.integer, .semicolon, .eof]
        let result = scanSource(source: source, compareWithExpectedTokens: expectedTokenTypes)
        
        XCTAssertTrue(result, "A source consisting solely of two forward slashes should be interpreted as as comment and return an empty list of tokens.")
    }
    
    func testMultiLineCommentHidesSecondTokenShouldReturnOneToken() {
        let source = "123;/*123*/"
        let expectedTokenTypes: [TokenType] = [.integer, .semicolon, .eof]
        let result = scanSource(source: source, compareWithExpectedTokens: expectedTokenTypes)
        
        XCTAssertTrue(result, "A source consisting solely of a multi-digit number and a multi-line comment consisting of number inside should return a single number token.")
    }
    
    // MARK: Strings
    func testSingleString() {
        let source = #""Hei på deg";"#
        let expectedTokenTypes: [TokenType] = [.string, .semicolon, .eof]
        let result = scanSource(source: source, compareWithExpectedTokens: expectedTokenTypes)
        
        XCTAssertTrue(result, "A source consisting of a string should return a single token of that string.")
    }
    
    // MARK: Mathematical expressions
    func testNumberPlusNumber() {
        let source = "123+123;"
        let expectedTokenTypes: [TokenType] = [.integer, .plus, .integer, .semicolon, .eof]
        let result = scanSource(source: source, compareWithExpectedTokens: expectedTokenTypes)
        
        XCTAssertTrue(result, "A number, an operator and a number should result in three tokens.")
    }
    
    func testNumberDivideNumber() {
        let source = "123/123;"
        let expectedTokenTypes: [TokenType] = [.integer, .slash, .integer, .semicolon, .eof]
        let result = scanSource(source: source, compareWithExpectedTokens: expectedTokenTypes)
        
        XCTAssertTrue(result, "A number, an operator and a number should result in three tokens (including EOF).")
    }
    
    // MARK: Print
    func testPrintStatementWithValue() {
        let source = #"print "Hello, world!";"#
        let expectedTokenTypes: [TokenType] = [.print, .string, .semicolon, .eof]
        let result = scanSource(source: source, compareWithExpectedTokens: expectedTokenTypes)
        
        XCTAssertTrue(result, "Print statement that prints a string was not tokenized correctly.")
    }
    
    func testPrintStatementWithBinaryNumberLiteralExpression() {
        let source = "print 1 + 1;"
        let expectedTokenTypes: [TokenType] = [.print, .integer, .plus, .integer, .semicolon, .eof]
        let result = scanSource(source: source, compareWithExpectedTokens: expectedTokenTypes)
        
        XCTAssertTrue(result, "Print statements that prints the result of adding two literal numbers not tokenized correctly.")
    }
    
    // MARK: Variable declarations
    func testVariableDeclarationWithInitialization() {
        let source = "var number = 3;"
        let expectedTokenTypes: [TokenType] = [.var, .identifier, .equal, .integer, .semicolon, .eof]
        let result = scanSource(source: source, compareWithExpectedTokens: expectedTokenTypes)
        
        XCTAssertTrue(result, "A var keyword, an identifier, an equals sign and a number should result in four tokens (including EOF).")
    }
    
    func testBooleanVariableDeclaration() {
        let source = "var test = true;"
        let expectedTokenTypes: [TokenType] = [.var, .identifier, .equal, .true, .semicolon, .eof]
        let result = scanSource(source: source, compareWithExpectedTokens: expectedTokenTypes)
        
        XCTAssertTrue(result, "Tokenizing of a boolean variable declaration failed.")
    }
    
    func testBooleanVariableDeclarationWithTypeAnnotation() {
        let source = "var test: Bool = false;";
        let expectedTokenTypes: [TokenType] = [.var, .identifier, .colon, .identifier, .equal, .false, .semicolon, .eof]
        let result = scanSource(source: source, compareWithExpectedTokens: expectedTokenTypes)
        
        XCTAssertTrue(result, "Tokenizing of a boolean variable declaration failed.")
    }
    
    func testBinayNumberLiteralExpression() {
        let source = "var test = 1 + 1;"
        let expectedTokenTypes: [TokenType] = [.var, .identifier, .equal, .integer, .plus, .integer, .semicolon, .eof]
        let result = scanSource(source: source, compareWithExpectedTokens: expectedTokenTypes)
        
        XCTAssertTrue(result, "Variable declaration for binary expression with number literal operands failed.")
    }
    
    // Conditionals
    func testValidIfStatementWithIfBranch() {
        let source = "if true {}"
        let expectedTokenTypes: [TokenType] = [.ifBranch, .true, .leftBrace, .rightBrace, .eof]
        let result = scanSource(source: source, compareWithExpectedTokens: expectedTokenTypes)
        
        XCTAssertTrue(result, "If statement with if branch was not scanned correctly.")
    }
    
    func testValidIfStatementWithIfAndElseBranch() {
        let source = "if true {} else {}"
        let expectedTokenTypes: [TokenType] = [
            .ifBranch, .true, .leftBrace, .rightBrace, .elseBranch, .leftBrace, .rightBrace, .eof
        ]
        let result = scanSource(source: source, compareWithExpectedTokens: expectedTokenTypes)
        
        XCTAssertTrue(result, "If statement with if and else branch was not scanned correctly.")
    }

}

extension NicTests {
    func scanSource(source: String, compareWithExpectedTokens expectedTokens: [TokenType]) -> Bool {
        let scanner = Scanner(source: source)
        let tokenTypes = scanner.scan().map { $0.type }
        return expectedTokens == tokenTypes
    }
}
