//
//  Environment.swift
//  Nic
//
//  Created by Eirik Vale Aase on 17/04/2019.
//

/// `Environment` handles the bindings between variables and values.
/// The opetional `enclosing` field is used for the enclosing environment.
/// The global environment, containing global declarations, have no such enclosing
/// environment, only environments nested inside the global scope.
class Environment {
    private var enclosing: Environment?
    private var values: [String: Any?] = [:]
    
    func define(name: String, value: Any?) {
        values[name] = value
    }
    
    func get(name: Token) throws -> Any? {
        guard values.keys.contains(name.lexeme) else {
            Nic.error(at: name.line, message: "Variable '\(name.lexeme)' could not be found in the current scope.")
            throw NicRuntimeError.undefinedVariable(name: name)
        }
        
        return values[name.lexeme] ?? nil
    }
    
    func ancestor(distance: Int) -> Environment? {
        var environment: Environment? = self
        
        for _ in 0..<distance {
            environment = environment?.enclosing
        }
        
        return environment
    }
    
    func get(at distance: Int, name: String) -> Any? {
        return ancestor(distance: distance)?.values[name] ?? nil
    }
    
    func assign(at distance: Int, name: Token, value: Any?) {
        ancestor(distance: distance)?.values[name.lexeme] = value
    }
}

extension Environment {
    convenience init(environment: Environment) {
        self.init()
        
        self.enclosing = environment
    }
}

extension Environment: CustomStringConvertible {
    var description: String {
        return values.map {
            return "\($0.key): \($0.value ?? "")"
        }.joined(separator: "\n")
    }
}
