//
//  NicResolverError.swift
//  Nic
//
//  Created by Eirik Vale Aase on 19/04/2019.
//

import Foundation

enum NicResolverError: Error {
    case undefinedVariable(name: Token)
}
