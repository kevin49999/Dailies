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
        case daysOfWeek

        init?(int: Int) {
            switch int {
            case 0:
                self = .created
            case 1:
                self = .daysOfWeek
            default:
                return nil
            }
        }
    }

    let classification: Classification
    let dateCreated: Date
    var name: String
    var todos: [Todo]
    var showCompleted: Bool
    var isWeekend: Bool {
        switch classification {
        case .daysOfWeek where name == "Sunday",
             .daysOfWeek where name == "Saturday":
            return true
        default:
            return false
        }
    }
    var visibleTodos: ArraySlice<Todo> {
        if showCompleted {
            return todos.prefix(Int.max)
        }
        return todos.prefix { !$0.completed }
    }

    init(
        classification: Classification,
        dateCreated: Date = .todayYearMonthDay(),
        name: String,
        todos: [Todo] = [],
        showCompleted: Bool = false
    ) {
        self.classification = classification
        self.dateCreated = dateCreated
        self.name = name
        self.todos = todos
        self.showCompleted = showCompleted
    }
}

// MARK: - Generated Lists

extension TodoList {
    static func createdTodoLists() -> [TodoList] {
        do {
            return try getCreated()
        } catch {
            return []
        }
    }

    static func daysOfWeekTodoLists(
        calendar: Calendar = .current,
        today: Date = .todayYearMonthDay()
    ) -> [TodoList] {
        guard let saved = try? getDaysOfWeek(), !saved.isEmpty else {
            return newDaysOfWeekTodoLists()
        }

        let new = newDaysOfWeekTodoLists()
        for list in new {
            let match = saved.first(where: { $0.name == list.name })!
            if match.dateCreated >= today {
                list.todos = match.todos
            }
        }
        return new
    }

    private static func newDaysOfWeekTodoLists(
        calendar: Calendar = .current,
        today: Date = .todayYearMonthDay()
    ) -> [TodoList] {
        return currentDaysOfWeek().enumerated().map { offset, day in
            TodoList(
                classification: .daysOfWeek,
                dateCreated: calendar.date(byAdding: DateComponents(day: offset), to: today)!,
                name: day
            )
        }
    }
}

// MARK: - Caching

extension TodoList {
    static func saveCreated(_ lists: [TodoList]) throws {
        try Cache.save(lists, path: "created")
    }

    static func saveDaysOfWeek(_ lists: [TodoList]) throws {
        try Cache.save(lists, path: "week")
    }

    private static func getCreated() throws -> [TodoList] {
        return try Cache.read(path: "created")
    }

    private static func getDaysOfWeek() throws -> [TodoList] {
        return try Cache.read(path: "week")
    }
}

fileprivate func currentDaysOfWeek(starting date: Date = Date(), calendar: Calendar = .current) -> [String] {
    let current = calendar.component(.weekday, from: date)
    let days = [1, 2, 3, 4, 5, 6, 7]
    var rearrangedDays = days
        .split(separator: current)
        .reversed()
        .flatMap { $0 }
    rearrangedDays.insert(current, at: 0)
    return rearrangedDays.map { calendar.weekdaySymbols[$0 - 1] }
}
