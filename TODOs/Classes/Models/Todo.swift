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
        self.completed = completed
    }
}

extension Todo: Equatable {
    static func == (lhs: Todo, rhs: Todo) -> Bool {
        // should prob include timestamp..
        return lhs.text == rhs.text && lhs.completed == rhs.completed
    }
}
