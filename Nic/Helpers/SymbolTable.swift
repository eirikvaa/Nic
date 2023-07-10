//
//  SymbolTable.swift
//  Nic
//
//  Created by Eirik Vale Aase on 22/04/2019.
//

class SymbolTableValue {
    var value: Any?
    var isMutable = false
    var isDefined = false

    init(value: Any?, isMutable: Bool = false, isDefined: Bool = false) {
        self.value = value
        self.isMutable = isMutable
        self.isDefined = isDefined
    }

    convenience init<Element>(value: Element, keyPath: ReferenceWritableKeyPath<SymbolTableValue, Element>) {
        self.init(value: value)

        self[keyPath: keyPath] = value
    }
}

class SymbolTable {
    private var bindings: [[String: SymbolTableValue]] = [[:]]

    static let shared = SymbolTable()
    private init() {}

    func get<Element>(name: Token, at distance: Int, keyPath: ReferenceWritableKeyPath<SymbolTableValue, Element>) throws -> Element? {
        guard distance >= 0 || distance - 1 >= 0 else {
            throw NicRuntimeError.undefinedVariable(name: name)
        }

        guard let value = bindings[distance][name.lexeme] else {
            return try get(name: name, at: distance - 1, keyPath: keyPath)
        }

        return value[keyPath: keyPath]
    }

    func get(name: Token, at distance: Int) throws -> SymbolTableValue? {
        guard distance >= 0 || distance - 1 >= 0 else {
            throw NicRuntimeError.undefinedVariable(name: name)
        }

        guard let value = bindings[distance][name.lexeme] else {
            return try get(name: name, at: distance - 1)
        }

        return value
    }

    func set<Element>(element: Element, at keyPath: ReferenceWritableKeyPath<SymbolTableValue, Element>, to token: Token, at distance: Int) {
        guard let value = bindings[distance][token.lexeme] else {
            // Create new value
            let _value = SymbolTableValue(value: element, keyPath: keyPath)
            bindings[distance][token.lexeme] = _value
            return
        }

        // Update existing value
        value[keyPath: keyPath] = element
    }

    func set(newRecord: SymbolTableValue, token: Token, distance: Int) {
        guard let existingRecord = bindings[distance][token.lexeme] else {
            bindings[distance][token.lexeme] = newRecord
            return
        }

        existingRecord.value = newRecord.value
    }

    func contains(token: Token, at distance: Int) -> Bool {
        return bindings[distance].keys.contains(token.lexeme)
    }

    func beginScope() {
        bindings.append([:])
    }
}

extension SymbolTable: CustomStringConvertible {
    var description: String {
        var content = "======================================\n"
        content += "Symbol table:\n\n"

        for i in 0 ..< bindings.count {
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
