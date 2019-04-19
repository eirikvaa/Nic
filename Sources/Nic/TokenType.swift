//
//  TokenType.swift
//  Nic
//
//  Created by Eirik Vale Aase on 10/03/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

// TODO: Create a namespace for the different token types, like one for mathematical operators?
enum TokenType: String {
    // literals
    case string
    case integer
    case double
    case `true`         = "true"
    case `false`        = "false"
    
    // operators
    case equal          = "="
    case plus           = "+"
    case minus          = "-"
    case slash          = "/"
    case star           = "*"
    
    // keywords
    case `var`          = "var"
    case const          = "const"
    case print          = "print"
    
    // punctuation
    case semicolon      = ";"
    case colon          = ":"
    case leftParen      = "("
    case rightParen     = ")"
    case leftBrace      = "{"
    case rightBrace     = "}"
    
    // other
    case identifier
    case eof            = "EOF"
}
