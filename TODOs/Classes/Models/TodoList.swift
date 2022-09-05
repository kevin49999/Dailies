//
//  TodoList.swift
//  TODOs
//
//  Created by Kevin Johnson on 1/26/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import Foundation
import CloudKit

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
    /// bad, but only use for custom lists
    var name: String
    var todos: [Todo]
    var showCompleted: Bool
    /// iCloud Record Name
    var recordName: String?

    var visible: [Todo] { showCompleted ? todos : incomplete }
    lazy var day: String = DateFormatters.dayOfWeek.string(from: dateCreated)
    lazy var incomplete: [Todo] = { todos.filter { !$0.completed } }()
    
    init(
        classification: Classification,
        dateCreated: Date = Date.todayMonthDayYear(),
        name: String = "",
        todos: [Todo] = [],
        showCompleted: Bool = !GeneralSettings.shared.hideCompleted,
        recordName: String? = nil
    ) {
        self.classification = classification
        self.dateCreated = dateCreated
        self.name = name
        self.todos = todos
        self.showCompleted = showCompleted
        self.recordName = recordName
    }

    init?(record: CKRecord) {
        guard let classificationInt = record["classification"] as? Int,
              let classification = Classification(rawValue: classificationInt),
              let dateCreated = record["dateCreated"] as? Date,
              let name = record["name"] as? String,
              let showCompleted = record["showCompleted"] as? Bool else { return nil }

        self.recordName = record.recordID.recordName
        self.classification = classification
        self.dateCreated = dateCreated
        self.name = name
        self.todos = [] // setting these with separate fetch
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
