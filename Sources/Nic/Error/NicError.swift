//
//  NicError.swift
//  Nic
//
//  Created by Eirik Vale Aase on 10/03/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

import Foundation

enum NicError: Error {
    case unexpectedToken(token: Token)
    case expectExpression(token: Token)
    case declarationTypeMismatch(token: Token)
    case invalidAssignment(type: NicType, token: Token)
    case invalidOperands(line: Int, lhsType: NicType, rhsType: NicType, operationType: TokenType)
}
