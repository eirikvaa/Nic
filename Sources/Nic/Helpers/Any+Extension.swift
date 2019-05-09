//
//  Any+Extension.swift
//  LLVM
//
//  Created by Eirik Vale Aase on 07/05/2019.
//

import Foundation

extension Optional where Wrapped == Any {
    func nicType() -> NicType? {
        switch self {
        case is Int: return .integer
        case is Double: return .double
        case is Bool: return .boolean
        case is String: return .string
        default: return nil
        }
    }
}
