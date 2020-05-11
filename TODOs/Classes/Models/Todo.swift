//
//  Todo.swift
//  TODOs
//
//  Created by Kevin Johnson on 1/26/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import Foundation

class Todo: Codable {
    var text: String
    var completed: Bool

    init(text: String, completed: Bool = false) {
        self.text = text
        self.completed = false
    }
}
