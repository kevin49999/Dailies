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
        list.move(sIndex: 3, destination: list, dIndex: 0) // 4 to top
        list.move(sIndex: 1, destination: list, dIndex: 3) // 1 to bottom

        XCTAssertEqual(
            list.todos, [
                .init(text: "4"),
                .init(text: "2", completed: true),
                .init(text: "3", completed: true),
                .init(text: "1")
            ]
        )
        XCTAssertEqual(
            list.incomplete, [
                .init(text: "4"),
                .init(text: "1")
            ]
        )
    }

    func testResortListTopTopBottom() {
        let list = TodoList(classification: .created, name: "Fun")
        _ = list.incomplete // ""
        list.add(todo: .init(text: "1"))
        list.add(todo: .init(text: "2"))
        list.add(todo: .init(text: "3"))
        list.add(todo: .init(text: "4"))

        list.move(sIndex: 3, destination: list, dIndex: 0)
        list.move(sIndex: 3, destination: list, dIndex: 1)
        list.move(sIndex: 3, destination: list, dIndex: 2)

        XCTAssertEqual(
            list.todos, [
                .init(text: "4"),
                .init(text: "3"),
                .init(text: "2"),
                .init(text: "1")
            ]
        )
        XCTAssertEqual(
            list.incomplete, [
                .init(text: "4"),
                .init(text: "3"),
                .init(text: "2"),
                .init(text: "1")
            ]
        )

        list.move(sIndex: 3, destination: list, dIndex: 0)
        list.move(sIndex: 3, destination: list, dIndex: 1)
        list.move(sIndex: 3, destination: list, dIndex: 2)

        XCTAssertEqual(
            list.todos, [
                .init(text: "1"),
                .init(text: "2"),
                .init(text: "3"),
                .init(text: "4")
            ]
        )
        XCTAssertEqual(
            list.incomplete, [
                .init(text: "1"),
                .init(text: "2"),
                .init(text: "3"),
                .init(text: "4")
            ]
        )
    }

    func testTwoItemListRearrange() {
        let list = TodoList(classification: .created, name: "Fun")
        _ = list.incomplete // ""
        list.add(todo: .init(text: "1"))
        list.add(todo: .init(text: "2"))

        list.move(sIndex: 1, destination: list, dIndex: 0)

        XCTAssertEqual(
            list.todos, [
                .init(text: "2"),
                .init(text: "1")
            ]
        )
        XCTAssertEqual(
            list.incomplete, [
                .init(text: "2"),
                .init(text: "1")
            ]
        )

        list.move(sIndex: 0, destination: list, dIndex: 1)

        XCTAssertEqual(
            list.todos, [
                .init(text: "1"),
                .init(text: "2")
            ]
        )
        XCTAssertEqual(
            list.incomplete, [
                .init(text: "1"),
                .init(text: "2")
            ]
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
            list.todos, [
                .init(text: "1"),
                .init(text: "2", completed: true)
            ]
        )
        XCTAssertEqual(
            list.incomplete, [
                .init(text: "1"),
            ]
        )

        list.move(sIndex: 1, destination: list, dIndex: 0)

        XCTAssertEqual(
            list.todos, [
                .init(text: "2", completed: true),
                .init(text: "1")
            ]
        )
        XCTAssertEqual(
            list.incomplete, [
                .init(text: "1"),
            ]
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
            list2.todos, [
                .init(text: "1"),
                .init(text: "2"),
                .init(text: "3")
            ]
        )
        XCTAssertEqual(
            list2.incomplete, [
                .init(text: "1"),
                .init(text: "2"),
                .init(text: "3")
            ]
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
        list.move(sIndex: 1, destination: list, dIndex: 0)
        list.toggleCompleted(index: 0)

        XCTAssertEqual(
            list.todos, [
                .init(text: "2"),
                .init(text: "1"),
                .init(text: "3")
            ]
        )
        XCTAssertEqual(
            list.incomplete, [
                .init(text: "2"),
                .init(text: "1"),
                .init(text: "3")
            ]
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
            list.todos, [
                .init(text: "1")
            ]
        )
        XCTAssertEqual(
            list.incomplete, [
                .init(text: "1")
            ]
        )
    }
}
