//
//  TodoListTests.swift
//  TODOsTests
//
//  Created by Kevin Johnson on 11/19/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import XCTest
@testable import TODOs

class TodoListTests: XCTestCase {

    func testOneListMoves() {
        let list = TodoList()
        list.showCompleted = true
        _ = list.incomplete // lazy var, "adds" twice in append if not set yet
        list.add(todo: .init(text: "1"))
        list.add(todo: .init(text: "2"))
        list.add(todo: .init(text: "3"))
        list.add(todo: .init(text: "4"))
        list.toggleCompleted(index: 1)
        list.toggleCompleted(index: 2)
        list.move(sIndex: 3, dIndex: 0) // 4 to top
        list.move(sIndex: 1, dIndex: 3) // 1 to bottom

        XCTAssertEqual(
            list.todos.map { $0.text },
            ["4", "2", "3", "1"]
        )
        XCTAssertEqual(
            list.todos.map { $0.completed },
            [false, true, true, false]
        )
        XCTAssertEqual(
            list.incomplete.map { $0.text },
            ["4", "1"]
        )
    }

    func testResortListTopTopBottom() {
        let list = TodoList()
        _ = list.incomplete // ""
        list.add(todo: .init(text: "1"))
        list.add(todo: .init(text: "2"))
        list.add(todo: .init(text: "3"))
        list.add(todo: .init(text: "4"))

        list.move(sIndex: 3, dIndex: 0)
        list.move(sIndex: 3, dIndex: 1)
        list.move(sIndex: 3, dIndex: 2)

        XCTAssertEqual(
            list.todos.map { $0.text },
            ["4", "3", "2", "1"]
        )
        XCTAssertEqual(
            list.incomplete.map { $0.text },
            ["4", "3", "2", "1"]
        )

        list.move(sIndex: 3, dIndex: 0)
        list.move(sIndex: 3, dIndex: 1)
        list.move(sIndex: 3, dIndex: 2)

        XCTAssertEqual(
            list.todos.map { $0.text },
            ["1", "2", "3", "4"]
        )
        XCTAssertEqual(
            list.incomplete.map { $0.text },
            ["1", "2", "3", "4"]
        )
    }

    func testTwoItemListRearrange() {
        let list = TodoList()
        _ = list.incomplete // ""
        list.add(todo: .init(text: "1"))
        list.add(todo: .init(text: "2"))

        list.move(sIndex: 1, dIndex: 0)

        XCTAssertEqual(
            list.todos.map { $0.text },
            ["2", "1"]
        )
        XCTAssertEqual(
            list.incomplete.map { $0.text },
            ["2", "1"]
        )

        list.move(sIndex: 0, dIndex: 1)

        XCTAssertEqual(
            list.todos.map { $0.text },
            ["1", "2"]
        )
        XCTAssertEqual(
            list.incomplete.map { $0.text },
            ["1", "2"]
        )
    }

    func testMoveCompleted() {
        let list = TodoList()
        _ = list.incomplete // ""
        list.showCompleted = true
        list.add(todo: .init(text: "1"))
        list.add(todo: .init(text: "2"))
        list.toggleCompleted(index: 1)

        XCTAssertEqual(
            list.todos.map { $0.text },
            ["1", "2"]
        )
        XCTAssertEqual(
            list.todos.map { $0.completed },
            [false, true]
        )
        XCTAssertEqual(
            list.incomplete.map { $0.text },
            ["1"]
        )

        list.move(sIndex: 1, destination: list, dIndex: 0)

        XCTAssertEqual(
            list.todos.map { $0.text },
            ["2", "1"]
        )
        XCTAssertEqual(
            list.todos.map { $0.completed },
            [true, false]
        )
        XCTAssertEqual(
            list.incomplete.map { $0.text },
            ["1"]
        )
    }

    func testMultiListMoves() {
        let list = TodoList()
        _ = list.incomplete // ""
        list.add(todo: .init(text: "1"))
        list.add(todo: .init(text: "2"))
        list.add(todo: .init(text: "3"))

        let list2 = TodoList()

        list.move(sIndex: 2, destination: list2, dIndex: 0)
        list.move(sIndex: 1, destination: list2, dIndex: 0)
        list.move(sIndex: 0, destination: list2, dIndex: 0)

        XCTAssertEqual(
            list.todos, []
        )
        XCTAssertEqual(
            list.incomplete, []
        )
        XCTAssertEqual(
            list2.todos.map { $0.text },
            ["1", "2", "3"]
        )
        XCTAssertEqual(
            list2.incomplete.map { $0.text },
            ["1", "2", "3"]
        )
    }

    func testToggleMoveCompleted() {
        let list = TodoList()
        _ = list.incomplete // ""
        list.showCompleted = true
        list.add(todo: .init(text: "1"))
        list.add(todo: .init(text: "2"))
        list.add(todo: .init(text: "3"))
        list.toggleCompleted(index: 1)
        list.move(sIndex: 1, dIndex: 0)
        list.toggleCompleted(index: 0)

        XCTAssertEqual(
            list.todos.map { $0.text },
            ["2", "1", "3"]
        )
        XCTAssertEqual(
            list.incomplete.map { $0.text },
            ["2", "1", "3"]
        )
    }

    func testToggleCompletedSingleItemList() {
        let list = TodoList()
        _ = list.incomplete // ""
        list.showCompleted = true
        list.add(todo: .init(text: "1"))
        list.toggleCompleted(index: 0)
        list.toggleCompleted(index: 0)

        XCTAssertEqual(
            list.todos.map { $0.text },
            ["1"]
        )
        XCTAssertEqual(
            list.incomplete.map { $0.text },
            ["1"]
        )
    }

    func testDuplicate() {
        let list = TodoList()
        _ = list.incomplete // ""
        let todo = Todo(text: "1")
        list.add(todo: todo)
        XCTAssertEqual(
            list.incomplete.map { $0.text },
            ["1"]
        )
        list.duplicate(at: 0)

        XCTAssertEqual(
            list.incomplete.map { $0.text },
            ["1", "1"]
        )
        XCTAssertTrue(list.todos[0] === todo)

        list.toggleCompleted(index: 0)
        list.toggleCompleted(index: 0)
        list.showCompleted = true
        list.duplicate(at: 1)

        XCTAssertEqual(
            list.todos.map { $0.text },
            ["1", "1", "1"]
        )
        XCTAssertEqual(
            list.todos.map { $0.completed },
            [true, true, true]
        )
    }

    func testToggleShowHideFromCompleted() {
        let list = TodoList()
        _ = list.incomplete // ""
        list.add(todo: .init(text: "1"))
        list.add(todo: .init(text: "2"))
        list.add(todo: .init(text: "3"))
        list.add(todo: .init(text: "4"))
        list.add(todo: .init(text: "5"))
        list.showCompleted = true
        list.toggleCompleted(index: 1)
        list.toggleCompleted(index: 3)

        list.showCompleted = false
        XCTAssertEqual(
            list.visible.map { $0.text },
            ["1", "3", "5"]
        )

        list.toggleCompleted(index: 0)
        list.showCompleted = true
        list.toggleCompleted(index: 0)
        list.showCompleted = false
        XCTAssertEqual(
            list.visible.map { $0.text },
            ["1", "3", "5"]
        )
    }

    func testToggleShowHideFromAll() {
        let list = TodoList()
        _ = list.incomplete // ""
        list.showCompleted = true
        list.add(todo: .init(text: "1"))
        list.add(todo: .init(text: "2"))
        list.add(todo: .init(text: "3"))
        list.add(todo: .init(text: "4"))
        list.add(todo: .init(text: "5"))
        list.toggleCompleted(index: 1)
        list.toggleCompleted(index: 3)
        list.toggleCompleted(index: 1)
        list.toggleCompleted(index: 3)
        list.showCompleted = false

        XCTAssertEqual(
            list.incomplete.map { $0.text },
            ["1", "2", "3", "4", "5"]
        )
        XCTAssertEqual(
            list.todos.map { $0.completed },
            [Bool](repeating: false, count: 5)
        )
    }

    // MARK: - Staying in Sync

    func testGeneratingNewListAfterMonthsBreak() {
        let marchFirst = Date.monthDayYearDate(month: 3, day: 1, year: 2021)
        let lists: [TodoList] = [
            .init(dateCreated: marchFirst),
            .init(dateCreated: marchFirst.byAddingDays(1)),
            .init(dateCreated: marchFirst.byAddingDays(2)),
            .init(dateCreated: marchFirst.byAddingDays(3)),
            .init(dateCreated: marchFirst.byAddingDays(4)),
            .init(dateCreated: marchFirst.byAddingDays(5)),
            .init(dateCreated: marchFirst.byAddingDays(6)),
        ]
        // should throw out the old current in favor of generating a new list
        let current = TodoList.daysOfWeekTodoLists(current: lists)
        let new = TodoList.newDaysOfWeekTodoLists()
        XCTAssertEqual(current, new)
    }

    func testTimeZoneSwitch() {
        // TODO: need re-written test, that can get to fail first
    }

    func testMidWeekRegenerate() {
        let current: [TodoList] = [
            .init(nameDayMonth: "", weekDay: "", uniqueDay: "4/04/2024"),
            .init(nameDayMonth: "", weekDay: "", uniqueDay: "4/05/2024"),
            .init(nameDayMonth: "", weekDay: "", uniqueDay: "4/06/2024"),
            .init(nameDayMonth: "", weekDay: "", uniqueDay: "4/07/2024", todos: [.init(text: "1")]),
            .init(nameDayMonth: "", weekDay: "", uniqueDay: "4/08/2024", todos: [.init(text: "2")]),
            .init(nameDayMonth: "", weekDay: "", uniqueDay: "4/09/2024", todos: [.init(text: "3")]),
            .init(nameDayMonth: "", weekDay: "", uniqueDay: "4/10/2024"),
        ]
        let new: [TodoList] = [
            .init(nameDayMonth: "", weekDay: "", uniqueDay: "4/07/2024"),
            .init(nameDayMonth: "", weekDay: "", uniqueDay: "4/08/2024"),
            .init(nameDayMonth: "", weekDay: "", uniqueDay: "4/09/2024"),
            .init(nameDayMonth: "", weekDay: "", uniqueDay: "4/10/2024"),
            .init(nameDayMonth: "", weekDay: "", uniqueDay: "4/11/2024"),
            .init(nameDayMonth: "", weekDay: "", uniqueDay: "4/12/2024"),
            .init(nameDayMonth: "", weekDay: "", uniqueDay: "4/13/2024"),
        ]
        let final = TodoList.daysOfWeekTodoLists(current: current, new: new)
        XCTAssertEqual(final[0].uniqueDay, "4/07/2024")
        XCTAssertEqual(final[0].todos.first?.text, "1")
        XCTAssertEqual(final[1].uniqueDay, "4/08/2024")
        XCTAssertEqual(final[1].todos.first?.text, "2")
        XCTAssertEqual(final[2].uniqueDay, "4/09/2024")
        XCTAssertEqual(final[2].todos.first?.text, "3")
        XCTAssertEqual(final[3].uniqueDay, "4/10/2024")
        XCTAssertTrue(final[3].todos.isEmpty)
        XCTAssertEqual(final[4].uniqueDay, "4/11/2024")
        XCTAssertTrue(final[4].todos.isEmpty)
        XCTAssertEqual(final[5].uniqueDay, "4/12/2024")
        XCTAssertTrue(final[5].todos.isEmpty)
        XCTAssertEqual(final[6].uniqueDay, "4/13/2024")
        XCTAssertTrue(final[6].todos.isEmpty)
    }

    func testRollover() {
        let yesterday = Date.todayMonthDayYear().byAddingDays(-1)
        let lists: [TodoList] = [
            .init(dateCreated: yesterday, todos: [.init(text: "1")]),
            .init(dateCreated: yesterday.byAddingDays(1)),
            .init(dateCreated: yesterday.byAddingDays(2)),
            .init(dateCreated: yesterday.byAddingDays(3)),
            .init(dateCreated: yesterday.byAddingDays(4)),
            .init(dateCreated: yesterday.byAddingDays(5)),
            .init(dateCreated: yesterday.byAddingDays(6)),
        ]

        let settings = GeneralSettings()
        settings.toggleRollover(on: true)
        let yesterdayLists = TodoList.daysOfWeekTodoLists(
            settings: settings,
            current: lists
        )

        let todayLists = TodoList.daysOfWeekTodoLists(settings: settings, current: yesterdayLists)

        // 1 should now be on the first day, which is the day after
        XCTAssertEqual(todayLists[0].todos[0].text, "1")
    }
    
    func testMultiDayRollover() {
        let current: [TodoList] = [
            .init(nameDayMonth: "", weekDay: "", uniqueDay: "4/04/2024", todos: [.init(text: "1")]),
            .init(nameDayMonth: "", weekDay: "", uniqueDay: "4/05/2024", todos: [.init(text: "2")]),
            .init(nameDayMonth: "", weekDay: "", uniqueDay: "4/06/2024", todos: [.init(text: "3")]),
            .init(nameDayMonth: "", weekDay: "", uniqueDay: "4/07/2024"),
            .init(nameDayMonth: "", weekDay: "", uniqueDay: "4/08/2024"),
            .init(nameDayMonth: "", weekDay: "", uniqueDay: "4/09/2024"),
            .init(nameDayMonth: "", weekDay: "", uniqueDay: "4/10/2024"),
        ]
        let new: [TodoList] = [
            .init(nameDayMonth: "", weekDay: "", uniqueDay: "4/07/2024"),
            .init(nameDayMonth: "", weekDay: "", uniqueDay: "4/08/2024"),
            .init(nameDayMonth: "", weekDay: "", uniqueDay: "4/09/2024"),
            .init(nameDayMonth: "", weekDay: "", uniqueDay: "4/10/2024"),
            .init(nameDayMonth: "", weekDay: "", uniqueDay: "4/11/2024"),
            .init(nameDayMonth: "", weekDay: "", uniqueDay: "4/12/2024"),
            .init(nameDayMonth: "", weekDay: "", uniqueDay: "4/13/2024"),
        ]
        let final = TodoList.rolloverItems(current: current, new: new)
        XCTAssertEqual(final[0].text, "1")
        XCTAssertEqual(final[1].text, "2")
        XCTAssertEqual(final[2].text, "3")
    }
}

// MARK: - Date

extension Date {
    static func todayMonthDayYear(calendar: Calendar = .autoupdatingCurrent) -> Date {
        let comp = calendar.dateComponents([.year, .month, .day], from: Date())
        return monthDayYearDate(month: comp.month!, day: comp.day!, year: comp.year!)
    }

    static func monthDayYearDate(month: Int, day: Int, year: Int, calendar: Calendar = .autoupdatingCurrent) -> Date {
        let comp = DateComponents(year: year, month: month, day: day)
        return calendar.date(from: comp)!
    }
}
