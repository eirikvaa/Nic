//
//  SymbolTable.swift
//  Nic
//
//  Created by Eirik Vale Aase on 22/04/2019.
//

class SymbolTableValue {
    var value: Any?
    var isMutable = false
}

class SymbolTable {
    private var bindings: [[String: SymbolTableValue]] = [[:]]
    
    static let shared = SymbolTable()
    private init() {}
    
    func get<Element>(name: Token, at distance: Int, keyPath: ReferenceWritableKeyPath<SymbolTableValue, Element>) throws -> Element? {
        guard let value = bindings[distance][name.lexeme] else {
            throw NicRuntimeError.undefinedVariable(name: name)
        }
        
        return value[keyPath: keyPath]
    }
    
    func set<Element>(element: Element, at keyPath: ReferenceWritableKeyPath<SymbolTableValue, Element>, to token: Token, at distance: Int) {
        guard let value = bindings[distance][token.lexeme] else {
            // Create new value
            let _value = SymbolTableValue()
            _value[keyPath: keyPath] = element
            bindings[distance][token.lexeme] = _value
            return
        }
        
        // Update existing value
        value[keyPath: keyPath] = element
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
                return key + " value: \(value[keyPath: \.value] ?? "")"
            }.joined(separator: "")
            content += "\n\n"
        }
        
        content += "======================================\n"
        
        return content
    }
}
