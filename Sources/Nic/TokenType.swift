//
//  TokenType.swift
//  Nic
//
//  Created by Eirik Vale Aase on 10/03/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

import Foundation

enum TokenType: String {
    case string
    case number
    case bang
    case slash
    case identifier
    case `var`
    case equal
    case plus
    case minus
    case semicolon
    case eof
}
