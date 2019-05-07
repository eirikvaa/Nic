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
        case _ as Int: return .integer
        case _ as Double: return .double
        case _ as Bool: return .boolean
        case _ as String: return .string
        default: return nil
        }
    }
}
