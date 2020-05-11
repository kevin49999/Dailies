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
    lazy var incomplete: [Todo] = {
        return todos.filter { !$0.completed }
    }()
    var visible: [Todo] {
        return showCompleted ? todos : incomplete
    }
    var isWeekend: Bool {
        switch classification {
        case .daysOfWeek where name == "Sunday",
             .daysOfWeek where name == "Saturday":
            return true
        default:
            return false
        }
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

// MARK: - Model Updates.. mv

extension TodoList {
    func move(sIndex: Int, destination: TodoList, dIndex: Int) {
        // Remove (could be own method)
        let todo: Todo
        if showCompleted {
            todo = todos.remove(at: sIndex)
            if !todo.completed, let oIndex = incomplete.firstIndex(where: { $0 === todo }) {
                incomplete.remove(at: oIndex)
            }
        } else {
            todo = incomplete.remove(at: sIndex)
            let oIndex = todos.firstIndex(where: { $0 === todo })!
            todos.remove(at: oIndex)
        }

        // Re-insert (could be own method)
        if destination.showCompleted {
            let other: Todo?
            if self === destination {
                // just removed, need to not insert out of bounds at end
                other = destination.todos[min(dIndex, destination.todos.count - 1)]
            } else {
                other = destination.todos.count > 0 ? destination.todos[dIndex] : nil
            }
            destination.todos.insert(todo, at: dIndex)
            
            if let o = other, let oIndex = destination.incomplete.firstIndex(where: { $0 === o }) {
                destination.incomplete.insert(todo, at: oIndex)
            } else {
                // find nearest incomplete to the left...
                var i = dIndex - 1
                var lTodo: Todo?
                while i >= 0 && lTodo == nil {
                    if !destination.todos[i].completed {
                        lTodo = destination.todos[i]
                        print("Fallback after:", lTodo?.text ?? "", "index:", i)
                    } else {
                        i -= 1
                    }
                }
                destination.incomplete.insert(todo, at: i + 1)
            }
        } else {
            // TODO: Do this too..
            let other = destination.incomplete[min(dIndex, destination.incomplete.count - 1)]
            if !todo.completed {
                destination.incomplete.insert(todo, at: dIndex)
            }

            if let oIndex = destination.todos.firstIndex(where: { $0 === other }) {
                destination.todos.insert(todo, at: oIndex)
            } else {
                let fallbackIndex = min(destination.todos.count - 1, dIndex)
                destination.todos.insert(todo, at: fallbackIndex)
            }
        }
    }

    // More..
}
