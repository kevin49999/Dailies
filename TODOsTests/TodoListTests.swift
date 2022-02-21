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
        let list = TodoList(classification: .created, name: "Fun")
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
        let list = TodoList(classification: .created, name: "Fun")
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
        let list = TodoList(classification: .created, name: "Fun")
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
        let list = TodoList(classification: .created, name: "Fun")
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
        let list = TodoList(classification: .created, name: "Fun")
        _ = list.incomplete // ""
        list.add(todo: .init(text: "1"))
        list.add(todo: .init(text: "2"))
        list.add(todo: .init(text: "3"))

        let list2 = TodoList(classification: .created, name: "Work")

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
        let list = TodoList(classification: .created, name: "Fun")
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
        let list = TodoList(classification: .created, name: "Fun")
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
        let list = TodoList(classification: .created, name: "Fun")
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
        let list = TodoList(classification: .created, name: "Bug 1/4")
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
        let list = TodoList(classification: .created, name: "Bug 1/4")
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
            .init(classification: .daysOfWeek, dateCreated: marchFirst),
            .init(classification: .daysOfWeek, dateCreated: marchFirst.byAddingDays(1)),
            .init(classification: .daysOfWeek, dateCreated: marchFirst.byAddingDays(2)),
            .init(classification: .daysOfWeek, dateCreated: marchFirst.byAddingDays(3)),
            .init(classification: .daysOfWeek, dateCreated: marchFirst.byAddingDays(4)),
            .init(classification: .daysOfWeek, dateCreated: marchFirst.byAddingDays(5)),
            .init(classification: .daysOfWeek, dateCreated: marchFirst.byAddingDays(6)),
        ]
        // should throw out the old current in favor of generating a new list
        let current = TodoList.daysOfWeekTodoLists(currentLists: lists)
        let new = TodoList.newDaysOfWeekTodoLists()
        XCTAssertEqual(current, new)
    }

    func testTimeZoneSwitch() {
        let today = Date() // keeps the timezone..
        print(today)
        let lists: [TodoList] = [
            .init(classification: .daysOfWeek, dateCreated: today, todos: [.init(text: "1")]),
            .init(classification: .daysOfWeek, dateCreated: today.byAddingDays(1), todos: [.init(text: "2")]),
            .init(classification: .daysOfWeek, dateCreated: today.byAddingDays(2), todos: [.init(text: "3")]),
            .init(classification: .daysOfWeek, dateCreated: today.byAddingDays(3)),
            .init(classification: .daysOfWeek, dateCreated: today.byAddingDays(4)),
            .init(classification: .daysOfWeek, dateCreated: today.byAddingDays(5)),
            .init(classification: .daysOfWeek, dateCreated: today.byAddingDays(6)),
        ]
        let current = TodoList.daysOfWeekTodoLists(currentLists: lists)
        XCTAssertEqual(current, lists)
    }
}
