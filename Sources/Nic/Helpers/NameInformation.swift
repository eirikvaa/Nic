//
//  NameInformation.swift
//  Nic
//
//  Created by Eirik Vale Aase on 19/04/2019.
//

import Foundation
import LLVM

/// `NameInformation` holds vital information about a variable
struct NameInformation {
    var value: Any?
    var isMutable: Bool
    var irValue: IRValue?
    
    init(value: Any?, isMutable: Bool) {
        self.value = value
        self.isMutable = isMutable
    }
}
