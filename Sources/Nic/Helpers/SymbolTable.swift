//
//  SymbolTable.swift
//  Nic
//
//  Created by Eirik Vale Aase on 22/04/2019.
//

class SymbolTable {
    private var bindings: [[String: Any?]] = [[:]]
    
    static let shared = SymbolTable()
    private init() {}
    
    func get(name: Token, at distance: Int) throws -> Any? {
        guard let value = bindings[distance][name.lexeme] else {
            throw NicRuntimeError.undefinedVariable(name: name)
        }
        
        return value
    }
    
    func set(value: Any?, to token: Token, at distance: Int) {
        bindings[distance][token.lexeme] = value
    }
    
    func beginScope() {
        bindings.append([:])
    }
}

extension SymbolTable: CustomStringConvertible {
    var description: String {
        var content = "======================================\n"
        content += "Symbol table:\n\n"
        
        for i in 0..<bindings.count {
            let tabString = Array(repeating: "\t", count: i).joined(separator: "")
            let tabTitleString = Array(repeating: "\t", count: i).joined(separator: "")
            
            content += i == 0 ? tabTitleString + "Global scope (0)" : tabTitleString + "Local scope (\(i))"
            content += "\n" + tabString + bindings[i].map {
                let (key, value) = $0
                return key + " value: \(value ?? "")"
            }.joined(separator: "")
            content += "\n\n"
        }
        
        content += "======================================\n"
        
        return content
    }
}
