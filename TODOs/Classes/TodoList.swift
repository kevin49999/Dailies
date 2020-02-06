//
//  TodoList.swift
//  TODOs
//
//  Created by Kevin Johnson on 1/26/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import Foundation

class TodoList: Codable {
    enum Classification: String, Codable {
        case created
        case dayOfWeek
    }

    let classification: Classification
    let dateCreated: Date
    var name: String
    var todos: [Todo]

    init(
        classification: Classification,
        dateCreated: Date = Date(),
        name: String,
        todos: [Todo] = []
    ) {
        self.classification = classification
        self.dateCreated = dateCreated
        self.name = name
        self.todos = todos
    }
}

extension TodoList {
    static func createdTodoLists() -> [TodoList] {
        guard let saved = try? getCreated() else {
            return []
        }
        return saved
    }

    static func daysOfWeekTodoLists(
        calendar: Calendar = .current,
        today: Date = .todayMonthDateYear()
    ) -> [TodoList] {
        guard let saved = try? getDaysOfWeek() else {
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
        today: Date = .todayMonthDateYear()
    ) -> [TodoList] {
        return currentDaysOfWeek().enumerated().map { offset, day in
            return TodoList(
                classification: .dayOfWeek,
                dateCreated: calendar.date(byAdding: DateComponents(day: offset), to: today)!,
                name: day
            )
        }
    }
}

// MARK: - Caching

extension TodoList {
    static func saveLists(_ lists: [TodoList]) throws {
        var created: [TodoList] = []
        var daysOfweek: [TodoList] = []
        for list in lists {
            switch list.classification {
            case .created:
                created.append(list)
            case .dayOfWeek:
                daysOfweek.append(list)
            }
        }
        try? saveCreated(created)
        try? saveDaysOfWeek(daysOfweek)
    }

    private static func saveCreated(_ lists: [TodoList]) throws {
        try Cache.save(lists, path: "created")
    }

    private static func saveDaysOfWeek(_ lists: [TodoList]) throws {
        try Cache.save(lists, path: "week")
    }

    private static func getCreated() throws -> [TodoList] {
        return try Cache.read(path: "created")
    }

    private static func getDaysOfWeek() throws -> [TodoList] {
        return try Cache.read(path: "week")
    }
}

// MARK: - Random

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
