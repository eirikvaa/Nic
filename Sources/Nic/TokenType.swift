//
//  TokenType.swift
//  Nic
//
//  Created by Eirik Vale Aase on 10/03/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

// TODO: Create a namespace for the different token types, like one for mathematical operators?
enum TokenType: String {
    // primary values
    case string
    case integer
    case double
    case identifier
    
    // operators
    case equal          = "="
    case plus           = "+"
    case minus          = "-"
    case slash          = "/"
    case star           = "*"
    
    // boolean
    case `true`         = "true"
    case `false`        = "false"
    
    // keywords
    case `var`          = "var"
    case const          = "const"
    case print          = "print"
    
    // other
    case semicolon      = ";"
    case colon          = ":"
    case leftParen      = "("
    case rightParen     = ")"
    case leftBrace      = "{"
    case rightBrace     = "}"
    case eof            = "EOF"
}
