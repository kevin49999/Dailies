//
//  TodoList.swift
//  TODOs
//
//  Created by Kevin Johnson on 1/26/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import Foundation

class TodoList: Codable {
    let nameDayMonth: String
    let weekDay: String
    var todos: [Todo]
    var showCompleted: Bool
    var visible: [Todo] { showCompleted ? todos : incomplete }
    lazy var incomplete: [Todo] = { todos.filter { !$0.completed } }()
    
    init(
        dateCreated: Date = Date(),
        todos: [Todo] = [],
        showCompleted: Bool = !GeneralSettings.shared.hideCompleted
    ) {
        self.nameDayMonth = DateFormatters.daysOfWeekNameDayMonth.string(from: dateCreated)
        self.weekDay = DateFormatters.dayOfWeek.string(from: dateCreated)
        self.todos = todos
        self.showCompleted = showCompleted
    }
}

// MARK: - Hashable

extension TodoList: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(nameDayMonth)
        hasher.combine(weekDay)
        hasher.combine(todos)
        hasher.combine(showCompleted)
    }

    static func == (lhs: TodoList, rhs: TodoList) -> Bool {
        lhs.nameDayMonth == rhs.nameDayMonth &&
        lhs.weekDay == rhs.weekDay &&
        lhs.todos == rhs.todos &&
        lhs.showCompleted == rhs.showCompleted
    }
}
