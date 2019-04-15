//
//  NicError.swift
//  Nic
//
//  Created by Eirik Vale Aase on 15/04/2019.
//

import Foundation

struct NicError {
    static func error(_ line: Int, message: String) {
        print("Line \(line): \(message)")
    }
    
    static func error(_ line: Int, error: Error) {
        print("Line \(line): \(error)")
    }
}
