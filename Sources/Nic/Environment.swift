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
    
    static let shared = Environment()
    private init() {}
    
    func define(name: String, value: Any?) {
        values[name] = value
    }
    
    func get(name: Token) throws -> Any? {
        guard values.keys.contains(name.lexeme) else {
            throw NicRuntimeError.undefinedVariable(name: name)
        }
        
        return values[name.lexeme] ?? nil
    }
}
