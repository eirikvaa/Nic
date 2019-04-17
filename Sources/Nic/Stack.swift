//
//  File.swift
//  Nic
//
//  Created by Eirik Vale Aase on 17/04/2019.
//

import Foundation

struct Stack<Element> {
    private var array: [Element] = []
    
    var isEmpty: Bool {
        return array.isEmpty
    }
    
    var count: Int {
        return array.count
    }
    
    mutating func push(_ element: Element) {
        array.append(element)
    }
    
    @discardableResult
    mutating func pop() -> Element? {
        return array.popLast()
    }
    
    mutating func peek() -> Element? {
        return array.last
    }
    
    subscript(index: Int) -> Element {
        return array[index]
    }
}

extension Stack: ExpressibleByArrayLiteral {
    typealias ArrayLiteralElement = Element
    
    init(arrayLiteral elements: Element...) {
        array.append(contentsOf: elements)
    }
}
