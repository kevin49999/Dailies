//
//  TodoList.swift
//  TODOs
//
//  Created by Kevin Johnson on 1/26/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import Foundation

class TodoList: Codable {
    /// used in main app UI
    let nameDayMonth: String
    /// used in widget UI for title
    let weekDay: String
    /// used for comparing w/ out using Date object
    let uniqueDay: String
    /// only used by widget still, optional because may not be set for testing
    let dateCreated: Date?
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
        self.uniqueDay = DateFormatters.uniqueDay.string(from: dateCreated)
        self.dateCreated = dateCreated
        self.todos = todos
        self.showCompleted = showCompleted
    }
    
    init(
        nameDayMonth: String,
        weekDay: String,
        uniqueDay: String,
        todos: [Todo] = [],
        showCompleted: Bool = !GeneralSettings.shared.hideCompleted
    ) {
        self.nameDayMonth = nameDayMonth
        self.weekDay = weekDay
        self.uniqueDay = uniqueDay
        self.dateCreated = nil
        self.todos = todos
        self.showCompleted = showCompleted
    }}

// MARK: - Hashable

extension TodoList: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(uniqueDay)
        hasher.combine(todos)
        hasher.combine(showCompleted)
    }

    static func == (lhs: TodoList, rhs: TodoList) -> Bool {
        lhs.uniqueDay == rhs.uniqueDay &&
        lhs.todos == rhs.todos &&
        lhs.showCompleted == rhs.showCompleted
    }
}
