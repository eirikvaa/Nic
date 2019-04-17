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
    func testNoThrowForAWellFormedProgram() {
        let tokens: [Token] = [
            Token(type: .var, lexeme: "var", literal: nil, line: 0),
            Token(type: .identifier, lexeme: "hello", literal: "hello", line: 0),
            Token(type: .equal, lexeme: "=", literal: nil, line: 0),
            Token(type: .string, lexeme: "hello", literal: "hello", line: 0),
            Token(type: .semicolon, lexeme: ";", literal: nil, line: 0),
            Token(type: .eof, lexeme: "EOF", literal: nil, line: 0)
        ]
        
        var parser = Parser(tokens: tokens)
        
        XCTAssertNoThrow(parser.parseTokens())
    }
}
