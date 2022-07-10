//
//  NicParserTests.swift
//  Nic
//
//  Created by Eirik Vale Aase on 10/03/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

import XCTest

@testable import Nic

class NicParserTests: XCTestCase {
    func testNoErrorsForAWellFormedProgram() {
        let tokens: [Token] = [
            Token(type: .var, lexeme: "var", literal: nil, line: 0),
            Token(type: .identifier, lexeme: "hello", literal: "hello", line: 0),
            Token(type: .equal, lexeme: "=", literal: nil, line: 0),
            Token(type: .string, lexeme: "hello", literal: "hello", line: 0),
            Token(type: .semicolon, lexeme: ";", literal: nil, line: 0),
            Token(type: .eof, lexeme: "EOF", literal: nil, line: 0)
        ]

        XCTAssertTrue(try parseTokens(tokens, compareWithExpectedNumberOfStatements: 1), "Variable declaration was not parsed correctly.")
    }

    func testParsingOfParenthesizesExpression() {
        let tokens: [Token] = [
            Token(type: .var, lexeme: "var", literal: nil, line: 0),
            Token(type: .identifier, lexeme: "hello", literal: "hello", line: 0),
            Token(type: .equal, lexeme: "=", literal: nil, line: 0),
            Token(type: .leftParen, lexeme: "(", literal: nil, line: 0),
            Token(type: .integer, lexeme: "1", literal: "1", line: 0),
            Token(type: .rightParen, lexeme: ")", literal: nil, line: 0),
            Token(type: .semicolon, lexeme: ";", literal: nil, line: 0),
            Token(type: .eof, lexeme: "EOF", literal: nil, line: 0)
        ]

        XCTAssertTrue(try parseTokens(tokens, compareWithExpectedNumberOfStatements: 1), "Grouped expression was not parsed correctly.")
    }
}

extension NicParserTests {
    func parseTokens(_ tokens: [Token], compareWithExpectedNumberOfStatements expectedStmtCount: Int) throws -> Bool {
        return Parser(tokens: tokens).parse().count == expectedStmtCount
    }
}
