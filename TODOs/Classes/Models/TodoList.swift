//
//  TodoList.swift
//  TODOs
//
//  Created by Kevin Johnson on 1/26/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//


/// MV
class GeneralSettings {

    enum Settings: String {
        case toggleHideCompleted = "toggle_hide_completed"
        case toggleRollover = "toggle_rollover"
    }

    static let shared = GeneralSettings()

    private let defaults: UserDefaults = .standard

    private init() { }

    var hideCompleted: Bool {
        if let hide = defaults.value(forKey: Settings.toggleHideCompleted.rawValue) as? Bool {
            return hide
        }
        return true
    }
    var rollover: Bool { defaults.bool(forKey: Settings.toggleRollover.rawValue) }

    func toggleHideCompleted(on: Bool) {
        // TODO: Should update all exising lists?
        defaults.set(on, forKey: Settings.toggleHideCompleted.rawValue)
    }

    func toggleRollover(on: Bool) {
        defaults.set(on, forKey: Settings.toggleRollover.rawValue)
    }
}

import Foundation

class TodoList: Codable {
    enum Classification: Int, Codable {
        case created = 0
        case daysOfWeek

        init(int: Int) {
            switch int {
            case 0:
                self = .created
            case 1:
                self = .daysOfWeek
            default:
                /// default value
                self = .daysOfWeek
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
    }

    static func == (lhs: TodoList, rhs: TodoList) -> Bool {
        return lhs.dateCreated == rhs.dateCreated && lhs.name == rhs.name
    }
}
