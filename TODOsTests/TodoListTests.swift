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

    override func setUp() {
        //
    }

    override func tearDown() {
        //
    }

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

    func testMultiListMoves() {
        ///
    }
}
