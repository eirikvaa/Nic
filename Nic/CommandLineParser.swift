//
//  CommandLineArgumentParser.swift
//  Nic
//
//  Created by Eirik Vale Aase on 30.05.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation

struct CommandLineParser {
    static func parse(_ arguments: [String]) {
        switch arguments.count {
        case 0:
            print("Please provide the path to a file.")
        case 2:
            run(path: arguments[1])
        default:
            break
        }
    }

    static func run(path: String) {
        guard let data = FileManager.default.contents(atPath: path) else { return }
        guard let source = String(data: data, encoding: .utf8) else { return }
        var scanner = Scanner(source: source)
        let tokens = scanner.scan()

        print(tokens)
    }
}
