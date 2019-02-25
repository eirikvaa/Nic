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
    var start: Character?
    var current: Character?
    var line = 0
    var source: String

    init(source: String) {
        self.source = source
    }

    mutating func scan() -> [Token] {
        var tokens: [Token] = []
        
        start = source.first
        current = start
        
        guard source.isEmpty == false else { return [] }

        for _ in source {
            if isDigit() {
                let startIndex = source.index(of: start!)
                let currentIndex = source.index(of: current!)
                let substring = source[startIndex! ..< currentIndex!]
                let number = Int(substring)
                let token = Token(type: .number, lexeme: String(substring), value: number)
                tokens.append(token)
                start = current
            }
        }

        return tokens
    }

    mutating func isDigit() -> Bool {
        var numberString = ""
        
        while let _ = Int(String(current!)) {
            numberString.append(String(current!))
            advance()
        }

        return Int(numberString) != nil
    }

    mutating func advance() {
        guard let current = current else { return }
        guard let currentIndex = source.index(of: current) else { return }
        let nextIndex = source.index(after: currentIndex)
        
        guard nextIndex < source.endIndex else { return }
        self.current = source[nextIndex]
    }
}
