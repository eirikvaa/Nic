//
//  NicTypeCheckerError.swift
//  LLVM
//
//  Created by Eirik Vale Aase on 17/04/2019.
//

import Foundation

enum NicTypeCheckerError: Error {
    case typeAnnotationMismatch(stmt: Stmt.Var)
}
