//
//  TokenType.swift
//  Nic
//
//  Created by Eirik Vale Aase on 10/03/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

import Foundation

enum TokenType: String {
    // primary values
    case string
    case number
    
    // operators
    case equal
    case plus
    case minus
    case slash
    case bang
    
    // boolean
    case `true`
    case `false`
    
    // keywords
    case `var`
    case const
    case function
    case print
    
    // other
    case identifier
    case semicolon
    case eof
    
    case leftParen
    case rightParen
    case leftBrace
    case rightBrace
}
