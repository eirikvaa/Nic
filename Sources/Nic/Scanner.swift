//
//  Scanner.swift
//  Nic
//
//  Created by Eirik Vale Aase on 30.05.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

/// The `Scanner` will take as input a string of characters, split it on whitespace and turn
/// it into a list of tokens.
struct Scanner {
    private var startIndex: String.Index
    private var currentIndex: String.Index
    private var line = 0
    private var source: String
    private var tokens: [Token] = []
    private let keywords: [String: TokenType] = [
        "var": .var,
        "const": .const,
        "print": .print,
        "true": .true,
        "false": .false
    ]

    init(source: String) {
        self.source = source
        startIndex = source.startIndex
        currentIndex = source.startIndex
    }
    
    mutating func scan() -> [Token] {
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
    private mutating func identifier() {
        while (peek()?.isAlphaNumeric == true && !isAtEnd()) {
            advance()
        }
        
        let identifier = String(source[startIndex..<currentIndex])
        let type = keywords[identifier] ?? .identifier
        addToken(type: type)
    }
    
    private mutating func multiLineComment() {
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
    
    private mutating func singleLineComment() {
        while peek()?.isNewline == false && !isAtEnd() {
            advance()
        }
    }
    
    private mutating func string() {
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
    
    private mutating func number() {
        while peek()?.isNumber == true && !isAtEnd() {
            advance()
        }
        
        if match(".") {
            while peek()?.isNumber == true && !isAtEnd() {
                advance()
            }
            
            let numberString = String(source[startIndex..<currentIndex])
            let number = Double(numberString)
            addToken(type: .double, literal: number)
        } else {
            let numberString = String(source[startIndex..<currentIndex])
            let number = Int(numberString)
            addToken(type: .integer, literal: number)
            return
        }
    }
}

// MARK: Helper methods

private extension Scanner {
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
                number()
            } else {
                identifier()
            }
        }
    }
    
    func isAtEnd() -> Bool {
        let index = source.distance(from: source.startIndex, to: currentIndex)
        return index >= source.count
    }
    
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
