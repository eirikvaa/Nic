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
    case missingRightValue
    case declarationTypeMismatch(token: Token)
    case invalidAssignment
}
