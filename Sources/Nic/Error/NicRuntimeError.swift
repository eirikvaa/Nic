//
//  NicRuntimeError.swift
//  Nic
//
//  Created by Eirik Vale Aase on 17/04/2019.
//

import Foundation

enum NicRuntimeError: Error {
    case undefinedVariable(name: Token)
    case illegalConstantMutation(name: Token)
}
