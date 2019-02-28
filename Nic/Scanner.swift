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
    var currentChar: String {
        return String(source[currentIndex])
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
                let token = Token(type: .number(value: number), lexeme: String(number))
                tokens.append(token)
            } else if isWhiteSpace() {
                whitespace()
            } else if isDoubleQuote() {
                let _string = string()
                let token = Token(type: .string(characters: _string), lexeme: _string)
                tokens.append(token)
            }  else if isForwardSlash() {
                switch peek() {
                case "/": singleLineComment()
                case "*": multiLineComment()
                default: break
                }
            } else {
                break
            }
        } while isFinished().isFalse

        return tokens
    }
}

// MARK: Consuming methods

extension Scanner {
    mutating func multiLineComment() {
        // The first character is a forward slash, and the next is a start (*),
        // so advance beyond that
        advance(steps: 2)
        
        while currentChar != "*" {
            if peek() == nil {
                break
            }
            
            advance()
        }
        
        // The next is expected to be "/", advance beyond that
        advance(steps: 2)
    }
    
    mutating func singleLineComment() {
        // We know the current character is a forward slash, so expect the next
        // character to be a forward slash also
        advance()
        
        while currentChar != "\n" {
            if peek() == nil {
                break
            }
            
            advance()
        }
    }
    
    mutating func string() -> String {
        var foundString = ""
        
        // We know we have found the start of the string, so advance to the first character
        advance()
        
        while currentChar != "\"" {
            foundString += currentChar
            
            if peek() == "\"" {
                break
            }
            
            advance()
        }
        
        return foundString
    }
    
    mutating func digit() -> Int {
        var numberString = ""
        
        while let _ = Int(currentChar) {
            numberString += currentChar
            
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
    func isForwardSlash() -> Bool {
        return currentChar == "/"
    }
    func isDoubleQuote() -> Bool {
        return currentChar == "\""
    }
    func isLineBreak() -> Bool {
        return currentChar == "\n"
    }
    
    func isWhiteSpace() -> Bool {
        return currentChar == " " || currentChar == "\n"
    }
    
    func isDigit() -> Bool {
        guard let _ = Int(currentChar) else {
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
    
    mutating func advance(steps: Int = 1) {
        currentIndex = source.index(currentIndex, offsetBy: steps)
    }
}
