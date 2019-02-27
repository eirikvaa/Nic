//
//  Scanner.swift
//  Nic
//
//  Created by Eirik Vale Aase on 30.05.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation

enum NicError: Error {
    case endOfFile
}

/// The Scanner will do the initial lexical analysis, turning the source into a list of tokens.
struct Scanner {
    var currentIndex: String.Index
    var line = 0
    var source: String
    var currentChar: Character {
        return source[currentIndex]
    }

    init(source: String) {
        self.source = source
        currentIndex = source.startIndex
    }
    
    mutating func scan() -> [Token] {
        var tokens: [Token] = []
        
        guard source.isEmpty.isFalse else {
            return []
        }

        repeat {
            if isDigit() {
                let number = digit()
                let token = Token(type: .number, lexeme: String(number), value: number)
                tokens.append(token)
            } else if isWhiteSpace() {
                whitespace()
            }
        } while isFinished().isFalse

        return tokens
    }
}

// MARK: Consuming methods

extension Scanner {
    mutating func digit() -> Int {
        var numberString = ""
        
        while let _ = Int(String(currentChar)) {
            numberString += String(currentChar)
            
            // Check if this was the last character in the source
            if peek() == nil {
                break
            }
            
            advance()
        }
        
        return Int(numberString) ?? 0
    }
    
    mutating func whitespace() {
        
        while isWhiteSpace() {
            if isLineBreak() {
                line += 1
            }
            
            advance()
        }
    }
}

// MARK: Analyzing methods

extension Scanner {
    func isLineBreak() -> Bool {
        return currentChar == "\n"
    }
    
    func isWhiteSpace() -> Bool {
        return currentChar == " " || currentChar == "\n"
    }
    
    func isDigit() -> Bool {
        guard let _ = Int(String(currentChar)) else {
            return false
        }
        
        return true
    }
    
    func isFinished() -> Bool {
        return currentIndex == source.endIndex || peek() == nil
    }
}

// MARK: Helper methods

extension Scanner {
    func peek() -> Character? {
        let nextIndex = source.index(after: currentIndex)
        guard nextIndex != source.endIndex else {
            return nil
        }
        
        return source[nextIndex]
    }
    
    mutating func advance() {
        currentIndex = source.index(after: currentIndex)
    }
}
