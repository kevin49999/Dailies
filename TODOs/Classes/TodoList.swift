//
//  TodoList.swift
//  TODOs
//
//  Created by Kevin Johnson on 1/26/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import Foundation

struct TodoList: Codable {
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
    static func createdTodoLists() -> [Self] {
        // TODO: Mocking, need to write extension to save, read.
        return [TodoList(classification: .created,
                         name: "Projects",
                         todos: [Todo(text: "New App"),
                                 Todo(text: "Automate Thing"),
                                 Todo(text: "Derp")]),
                TodoList(classification: .created,
                    name: "Finance",
                         todos: [Todo(text: "Upgrade Credit Card"),
                                 Todo(text: "Cancel Old Bank"),
                                 Todo(text: "$")]),
                TodoList(classification: .created,
                    name: "Misc.",
                         todos: [Todo(text: "Get New Plant"),
                                 Todo(text: "Do That Thing"),
                                 Todo(text: "Nice Thing")]
            )
        ]
    }

    static func daysOfWeekTodoLists() -> [Self] {
        let currentDays = currentDaysOfWeek()
        var savedDays: [TodoList] = []
        do {
            savedDays = try TodoList.getDaysOfWeek()
            assert(savedDays.count == 7)
            // TODO: Start Here!
            for (i, day) in savedDays.enumerated() {
                // if createdDate day > Date(), keep it, otherwise overwrite it
                

            }
            return []

        } catch {
            // TODO: Need to create with correct dateCreated.. month/date/year correctly, using start as reference
            return currentDays.map {
                TodoList(classification: .dayOfWeek, name: $0, todos: [])
            }
        }
    }
}

// MARK: - Save/Get

extension TodoList {
    static func saveCreated(_ lists: [TodoList]) throws {
        try Cache.save(lists, path: "created")
    }

    static func saveDaysOfWeek(_ lists: [TodoList]) throws {
        try Cache.save(lists, path: "week")
    }

    static func getCreated() throws -> [TodoList] {
        return try Cache.read(path: "created")
    }

    static func getDaysOfWeek() throws -> [TodoList] {
        return try Cache.read(path: "week")
    }
}

///
func currentDaysOfWeek(starting date: Date = Date(), calendar: Calendar = .current) -> [String] {
    let current = calendar.component(.weekday, from: date)
    let days = [1, 2, 3, 4, 5, 6, 7]
    var rearrangedDays = days
        .split(separator: current)
        .reversed()
        .flatMap { $0 }
    rearrangedDays.insert(current, at: 0)
    return rearrangedDays.map { calendar.weekdaySymbols[$0 - 1] }
}

//
extension Date {
    static func from(year: Int, month: Int, day: Int, calendar: Calendar = .current) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        guard let date = calendar.date(from: components) else {
            preconditionFailure("Invalid Date")
        }
        return date
    }
}
