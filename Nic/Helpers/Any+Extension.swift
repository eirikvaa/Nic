//
//  Any+Extension.swift
//  LLVM
//
//  Created by Eirik Vale Aase on 07/05/2019.
//

import Foundation

extension Optional where Wrapped == Any {
    func nicType() -> NicType? {
        return switch self {
        case is Int: .integer
        case is Double: .double
        case is Bool: .boolean
        case is String: .string
        default: nil
        }
    }
}
