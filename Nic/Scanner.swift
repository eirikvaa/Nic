//
//  Scanner.swift
//  Nic
//
//  Created by Eirik Vale Aase on 30.05.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation

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
        current = source.first

        for character in source {
            if isDigit(c: character) {
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

    mutating func isDigit(c: Character) -> Bool {
        var numberString = ""

        while let current = current, let _ = Int(String(c)) {
            numberString.append(c)
            advance()
        }

        return true
    }

    mutating func advance() {
        guard let current = current else { return }
        
        let endIndex = source.endIndex
        let beforeEndIndex = source.index(before: endIndex)

        guard let currentIndex = source.index(of: current), currentIndex < beforeEndIndex else { return }
        let nextIndex = source.index(after: currentIndex)
        self.current = source[nextIndex]
    }
}
