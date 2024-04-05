//
//  TodoList+Extensions.swift
//  TODOs
//
//  Created by Kevin Johnson on 12/6/20.
//

import Foundation

extension TodoList {
    static func daysOfWeekTodoLists(
        calendar: Calendar = .autoupdatingCurrent,
        settings: GeneralSettings = .shared,
        currentLists: [TodoList] = getCurrentDaysOfWeekList()
    ) -> [TodoList] {
        let new = newDaysOfWeekTodoLists()
        var map = [String: ([Todo], showCompleted: Bool)]()
        for l in currentLists {
            // only problem if wait a year, could fix
            map[l.nameDayMonth] = (l.todos, l.showCompleted)
        }
        for n in new {
            if let (todos, showCompleted) = map[n.nameDayMonth] {
                n.todos = todos
                n.showCompleted = showCompleted
            }
        }
        if settings.rollover, currentLists[0].nameDayMonth != new[0].nameDayMonth {
            // only check the first item in the list, the first to be removed
            // this will rollover whatever was in your last thrown out CURRENT day
            // so may not be yesterday if a break was taken
            // that's okay, would be a long rollover
            let rollover = currentLists[0].todos.filter { !$0.completed && !$0.isSetting }
            new[0].todos.append(contentsOf: rollover)
        }
        // always fresh
        return new
    }

    static func newDaysOfWeekTodoLists(
        calendar: Calendar = .autoupdatingCurrent,
        today: Date = Date()
    ) -> [TodoList] {
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

fileprivate func currentDaysOfWeek(starting date: Date = Date(), calendar: Calendar = .autoupdatingCurrent) -> [String] {
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

extension TodoList {
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
