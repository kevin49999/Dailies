//
//  TodoList+Extensions.swift
//  TODOs
//
//  Created by Kevin Johnson on 12/6/20.
//

import Foundation

extension TodoList {
    static func daysOfWeekTodoLists(
        settings: GeneralSettings = .shared,
        current: [TodoList] = getCurrentDaysOfWeekList(),
        new: [TodoList] = newDaysOfWeekTodoLists()
    ) -> [TodoList] {
        guard new.first?.uniqueDay != current.first?.uniqueDay else {
            // lists have same starting day, so return current list
            return current
        }
        
        var map = [String: ([Todo], showCompleted: Bool)]()
        for c in current {
            map[c.uniqueDay] = (c.todos, c.showCompleted)
        }
        for n in new {
            if let (todos, showCompleted) = map[n.uniqueDay] {
                n.todos = todos
                n.showCompleted = showCompleted
            }
        }
        // rollover
        if settings.rollover {
            let rollover = rolloverItems(current: current, new: new)
            // add to first day
            new.first?.todos.append(contentsOf: rollover)
        }
        return new
    }
    
    static func rolloverItems(current: [TodoList], new: [TodoList]) -> [Todo] {
        var rollover = [Todo]()
        for list in current {
            if list.uniqueDay == new.first?.uniqueDay {
                // you're at the current day, stop accumulating
                return rollover
            }
            let items = list.todos.filter { !$0.completed && !$0.isSetting }
            rollover.append(contentsOf: items)
        }
        return rollover
    }

    static func newDaysOfWeekTodoLists(today: Date = Date()) -> [TodoList] {
        currentDaysOfWeek().enumerated().map { offset, day in
            TodoList(dateCreated: today.byAddingDays(offset))
        }
    }

    private static func getCurrentDaysOfWeekList() -> [TodoList] {
        guard let lists = try? getDaysOfWeek(), !lists.isEmpty else {
            return newDaysOfWeekTodoLists()
        }
        return lists
    }
}

// MARK: - Caching

import WidgetKit

extension TodoList {
    static func saveDaysOfWeek(_ lists: [TodoList]) throws {
        try Cache.save(lists, path: "week")
        /// save in AppGroup for widget
        /// may not be the best place to put this
        let url = AppGroup.todos.containerURL.appendingPathComponent("week")
        let data = try JSONEncoder().encode(lists)
        try data.write(to: url)
        /// Reload single widget
        WidgetCenter.shared.reloadTimelines(ofKind: "TODOsWidget")
    }

    private static func getDaysOfWeek() throws -> [TodoList] {
        return try Cache.read(path: "week")
    }
}

// MARK: - Helper

fileprivate func currentDaysOfWeek(
    starting date: Date = Date(),
    calendar: Calendar = .autoupdatingCurrent
) -> [String] {
    let current = calendar.component(.weekday, from: date)
    let days = [1, 2, 3, 4, 5, 6, 7]
    var rearrangedDays = days
        .split(separator: current)
        .reversed()
        .flatMap { $0 }
    rearrangedDays.insert(current, at: 0)
    return rearrangedDays.map { calendar.weekdaySymbols[$0 - 1] }
}

// MARK: - Settings

extension Array where Element == TodoList {
    func applySetting(_ setting: Setting, calendar: Calendar = .autoupdatingCurrent) {
        applySettings([setting], calendar: calendar)
    }
    
    func applySettings(_ settings: [Setting], calendar: Calendar = .autoupdatingCurrent) {
        for setting in settings {
            switch setting.frequency {
            case .sundays,
                 .mondays,
                 .tuesdays,
                 .wednesdays,
                 .thursdays,
                 .fridays,
                 .saturdays:
                addSettingForDay(setting, setting.frequency.rawValue)
            case .weekends:
                addSettingForDays(setting, [0, 6])
            case .weekdays:
                addSettingForDays(setting, [Int](1...5))
            case .everyday:
                addSettingForDays(setting, [Int](0...6))
            }
        }
    }

    func addSettingForDays(_ setting: Setting, _ days: [Int]) {
        days.forEach { addSettingForDay(setting, $0) }
    }

    private func addSettingForDay(
        _ setting: Setting,
        _ day: Int,
        calendar: Calendar = .autoupdatingCurrent
    ) {
        guard let index = firstIndex(where: { $0.weekDay == calendar.standaloneWeekdaySymbols[day] }) else {
            assertionFailure("Could not weekday to day integer")
            return
        }
        self[index].addTodoFor(setting: setting)
    }
}

fileprivate extension TodoList {
    func addTodoFor(setting: Setting) {
        let todo = Todo(
            text: setting.name,
            settingUUID: setting.id.uuidString
        )
        // somehow generated can have same UUID as existing? checking that too
        if !todos.contains(where: { $0.settingUUID == setting.id.uuidString }) && !todos.contains(todo) {
            add(todo: todo)
        }
    }
}
