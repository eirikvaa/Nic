//
//  Scanner.swift
//  Nic
//
//  Created by Eirik Vale Aase on 30.05.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation

/// The Scanner will do the initial lexical analysis, turning the source into a list of tokens.
struct Scanner {
    var startIndex: String.Index
    var currentIndex: String.Index
    var line = 0
    var source: String
    var tokens: [Token] = []
    let keywords: [String: TokenType] = [
        "var": .var,
        "const": .const,
        "function": .function,
        "print": .print,
        "true": .true,
        "false": .false
    ]

    init(source: String) {
        self.source = source
        startIndex = source.startIndex
        currentIndex = source.startIndex
    }
    
    mutating func scanToken() throws {
        let c = advance()
        
        switch c {
        case "(": addToken(type: .leftParen)
        case ")": addToken(type: .rightParen)
        case "{": addToken(type: .leftBrace)
        case "}": addToken(type: .rightBrace)
        case "+": addToken(type: .plus)
        case "-": addToken(type: .minus)
        case "*": addToken(type: .bang)
        case " ": break
        case "\n": line += 1
        case "/":
            switch peek() {
            case "/": singleLineComment()
            case "*": try multiLineComment()
            default: addToken(type: .slash)
            }
        case "\"": try string()
        case "=": addToken(type: .equal)
        case ";": addToken(type: .semicolon)
        default:
            if isDigit(character: c) {
                digit()
            } else {
                identifier()
            }
        }
    }
    
    mutating func scanTokens() throws -> [Token] {
        while (!isAtEnd()) {
            startIndex = currentIndex
            try scanToken()
        }
        
        addToken(type: .eof)

        return tokens
    }
}

// MARK: Consuming methods

extension Scanner {
    mutating func identifier() {
        while ![" ", "\n", ";"].contains(peek()) && !isAtEnd() {
            advance()
        }
        
        let identifier = String(source[startIndex..<currentIndex])
        let type = keywords[identifier] ?? .identifier
        addToken(type: type)
    }
    
    mutating func multiLineComment() throws {
        advance(steps: 2) // Must advance beyond both / and *.
        
        while peek() != "*" && !isAtEnd() {
            if peek() == "\n" {
                line += 1
            }
            
            advance()
        }
        
        if isAtEnd() {
            throw NicScannerError.unterminatedMultiLineComment
        }
        
        advance() // advance beyond "*"
        if peek() == "/" {
            advance() // advance past last "/"
        } else {
            throw NicScannerError.unterminatedMultiLineComment
        }
    }
    
    mutating func singleLineComment() {
        advance() // advance beyond "/"
        
        while peek() != "\n" && !isAtEnd() {
            advance()
        }
    }
    
    mutating func string() throws {
        advance() // advance beyond first "
        
        while peek() != "\"" && !isAtEnd() {
            if peek() == "\n" {
                line += 1
            }
            
            advance()
        }
        
        if isAtEnd() {
            throw NicScannerError.unterminatedString
        }
        
        advance() // advance beyond last "
        
        let _startIndex = source.index(after: startIndex)
        let endIndex = source.index(before: currentIndex)
        
        let string = String(source[_startIndex..<endIndex])
        addToken(type: .string, literal: string)
    }
    
    mutating func digit() {
        while !isAtEnd() && isDigit(character: peek()) {
            advance()
        }
        
        let numberString = String(source[startIndex..<currentIndex])
        let number = Int(numberString) ?? 0
        addToken(type: .number, literal: number)
    }
}

// MARK: Analyzing methods

extension Scanner {
    func isAtEnd() -> Bool {
        let index = source.distance(from: source.startIndex, to: currentIndex)
        return index >= source.count
    }
    
    func isDigit(character: Character?) -> Bool {
        guard let character = character else {
            return false
        }
        
        return Int(String(character)) != nil
    }
}

// MARK: Helper methods

extension Scanner {
    func peek() -> Character? {
        guard !isAtEnd() else {
            return nil
        }
        
        return source[currentIndex]
    }
    
    @discardableResult
    mutating func advance(steps: Int = 1) -> Character {
        currentIndex = source.index(currentIndex, offsetBy: steps)
        return source[source.index(currentIndex, offsetBy: -steps)]
    }
    
    mutating func addToken(type: TokenType, literal: Any? = nil) {
        // The EOF token is the only token that should be included in the token list,
        // but which have an empty lexeme string, so handle that.
        let lexeme = type == .eof ? "EOF" : String(source[startIndex..<currentIndex])
        let token = Token(type: type, lexeme: lexeme, literal: literal, line: line)
        tokens.append(token)
    }
}
