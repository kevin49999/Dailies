//
//  TodoList.swift
//  TODOs
//
//  Created by Kevin Johnson on 1/26/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import Foundation

class TodoList: Codable {
    enum Classification: Int, Codable {
        case created = 0
        ///  removing
        case daysOfWeek
    }

    let classification: Classification
    let dateCreated: Date
    /// bad, but only only use for custom lists
    var name: String
    var todos: [Todo]
    var showCompleted: Bool
    var visible: [Todo] { showCompleted ? todos : incomplete }
    lazy var day: String = DateFormatters.dayOfWeek.string(from: dateCreated)
    lazy var incomplete: [Todo] = {
        return todos.filter { !$0.completed }
    }()
    
    init(
        classification: Classification,
        dateCreated: Date = Date.todayMonthDayYear(),
        name: String = "",
        todos: [Todo] = [],
        showCompleted: Bool = !GeneralSettings.shared.hideCompleted
    ) {
        self.classification = classification
        self.dateCreated = dateCreated
        self.name = name
        self.todos = todos
        self.showCompleted = showCompleted
    }
}

// MARK: - Hashable

extension TodoList: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(dateCreated)
        hasher.combine(todos)
    }

    static func == (lhs: TodoList, rhs: TodoList) -> Bool {
        return lhs.dateCreated == rhs.dateCreated && lhs.name == rhs.name && lhs.todos == rhs.todos
    }
}
