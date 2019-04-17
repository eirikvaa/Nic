//
//  Scanner.swift
//  Nic
//
//  Created by Eirik Vale Aase on 30.05.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation

/// The `Scanner` will take as input a string of characters, split it on whitespace and turn
/// it into a list of tokens.
struct Scanner {
    var startIndex: String.Index
    var currentIndex: String.Index
    var line = 0
    var source: String
    var tokens: [Token] = []
    let keywords: [String: TokenType] = [
        "var": .var,
        "print": .print,
        "true": .true,
        "false": .false
    ]

    init(source: String) {
        self.source = source
        startIndex = source.startIndex
        currentIndex = source.startIndex
    }
    
    mutating func scanToken() {
        // `advance` will increment `currentIndex` and return the character before
        // the character `currentIndex` corresponds to. That way, we never index
        // into the string with an invalid index.
        let character = advance()
        
        switch character {
        case "(": addToken(type: .leftParen)
        case ")": addToken(type: .rightParen)
        case "{": addToken(type: .leftBrace)
        case "}": addToken(type: .rightBrace)
        case ";": addToken(type: .semicolon)
        case ":": addToken(type: .colon)
        case "+": addToken(type: .plus)
        case "-": addToken(type: .minus)
        case "*": addToken(type: .star)
        case "=": addToken(type: .equal)
        case "\"": string()
        case " ": break
        case "\n": line += 1
        case "/":
            if match(Character("/")) {
                singleLineComment()
            } else if match(Character("*")) {
                multiLineComment()
            } else {
                addToken(type: .slash)
            }
        default:
            if character.isNumber {
                digit()
            } else {
                identifier()
            }
        }
    }
    
    mutating func scanTokens() -> [Token] {
        while (!isAtEnd()) {
            startIndex = currentIndex
            scanToken()
        }
        
        addToken(type: .eof)

        return tokens
    }
}

// MARK: Consuming methods

extension Scanner {
    mutating func identifier() {
        while ![" ", "\n", ";", ":"].contains(peek()) && !isAtEnd() {
            advance()
        }
        
        let identifier = String(source[startIndex..<currentIndex])
        let type = keywords[identifier] ?? .identifier
        addToken(type: type)
    }
    
    mutating func multiLineComment() {
        while peek() != "*" && !isAtEnd() {
            if peek()?.isNewline == true {
                line += 1
            }
            
            advance()
        }
        
        if isAtEnd() {
            Nic.error(at: line, message: "Undeterminated multi-line comment, missing '*'.")
            return
        }
        
        advance() // advance beyond "*"
        if peek() == "/" {
            advance() // advance past last "/"
        } else {
            Nic.error(at: line, message: "Undeterminated multi-line comment, missing '/'.")
            return
        }
    }
    
    mutating func singleLineComment() {
        while peek()?.isNewline == false && !isAtEnd() {
            advance()
        }
    }
    
    mutating func string() {
        advance() // advance beyond first "
        
        while peek() != "\"" && !isAtEnd() {
            if peek()?.isNewline == true {
                line += 1
            }
            
            advance()
        }
        
        if isAtEnd() {
            Nic.error(at: line, message: "Unterminated string")
            return
        }
        
        advance() // advance beyond last "
        
        let _startIndex = source.index(after: startIndex)
        let endIndex = source.index(before: currentIndex)
        
        let string = String(source[_startIndex..<endIndex])
        addToken(type: .string, literal: string)
    }
    
    mutating func digit() {
        while !isAtEnd() && peek()?.isNumber == true {
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
}

// MARK: Helper methods

extension Scanner {
    mutating func match(_ character: Character) -> Bool {
        guard isAtEnd() == false else {
            return false
        }
        
        guard peek() == character else {
            return false
        }
        
        advance()
        return true
    }
    
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
