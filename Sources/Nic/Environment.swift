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
    
    /// Bind the variable with the given name to the given value
    /// - parameters:
    ///     - name: Name of variable
    ///     - value: The value that `name` should be bound to
    func define(name: String, value: Any?) {
        values[name] = value
    }
    
    /// Get the value that `name` is bound to.
    /// - parameter name: The token representing a variable.
    /// - returns: The value that `name` is bound to.
    func get(name: Token) throws -> Any? {
        guard values.keys.contains(name.lexeme) else {
            Nic.error(at: name.line, message: "Variable '\(name.lexeme)' could not be found in the current scope.")
            throw NicRuntimeError.undefinedVariable(name: name)
        }
        
        return values[name.lexeme] ?? nil
    }
    
    /// Return the value bound to the variable named `name` that is `distance` jumps away from the current environment.
    /// - parameters:
    ///     - distance: The number of jumps away from the current environment
    ///     - name: The name of the variable for which a value should be found
    /// - returns: The value bound to the variable `name`
    func get(at distance: Int, name: String) -> Any? {
        return ancestor(distance: distance)?.values[name] ?? nil
    }
    
    /// Assign the value `value` to the variable corresponding to token `name` that is a number of `distance`
    /// jumps away from the current environment.
    /// - parameters:
    ///     - distance: The number of jumps from the current environment
    ///     - name: The token corresponding to the variable for which we assign a value to
    ///     - value: The value that should be assigned to the variable
    func assign(at distance: Int, name: Token, value: Any?) {
        ancestor(distance: distance)?.values[name.lexeme] = value
    }
    
    /// Return the environment, starting from the current, innermost environment,
    /// that is `distance` jumps away.
    /// - parameter distance: The number of jumps to be considered
    /// - returns: The environment that is `distance` jumps from the current environment, or `nil`
    func ancestor(distance: Int) -> Environment? {
        var environment: Environment? = self
        
        for _ in 0..<distance {
            environment = environment?.enclosing
        }
        
        return environment
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
