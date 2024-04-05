//
//  SettingsTests.swift
//  TODOsTests
//
//  Created by Kevin Johnson on 9/10/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import XCTest
@testable import TODOs

class SettingsTests: XCTestCase {

    func testApplyOneDaySetting() throws {
        let calendar = Calendar.current
        let days = TodoList.newDaysOfWeekTodoLists()
        let setting = Setting(name: "Monday", frequency: .mondays)
        days.applySetting(setting)

        for list in days {
            if list.weekDay == calendar.weekdaySymbols[setting.frequency.rawValue] {
                XCTAssertEqual(list.todos.map { $0.text }, ["Monday"])
            } else {
                XCTAssertEqual(list.todos, [])
            }
        }
    }

    func testApplyWeekendSetting() throws {
        let calendar = Calendar.current
        let days = TodoList.newDaysOfWeekTodoLists()
        let setting = Setting(name: "Weekend", frequency: .weekends)
        days.applySetting(setting)

        for list in days {
            switch list.weekDay {
            case calendar.weekdaySymbols[0],
                 calendar.weekdaySymbols[6]:
                XCTAssertEqual(list.todos.map { $0.text }, ["Weekend"])
            default:
                XCTAssertEqual(list.todos, [])
            }
        }
    }

    func testApplyWeekdaySetting() throws {
        let calendar = Calendar.current
        let days = TodoList.newDaysOfWeekTodoLists()
        let setting = Setting(name: "Weekdays", frequency: .weekdays)
        days.applySetting(setting)

        for list in days {
            switch list.weekDay {
            case calendar.weekdaySymbols[1],
                 calendar.weekdaySymbols[2],
                 calendar.weekdaySymbols[3],
                 calendar.weekdaySymbols[4],
                 calendar.weekdaySymbols[5]:
                XCTAssertEqual(list.todos.map { $0.text }, ["Weekdays"])
            default:
                XCTAssertEqual(list.todos, [])
            }
        }
    }

    func testApplyEverydaySetting() throws {
        let calendar = Calendar.current
        let days = TodoList.newDaysOfWeekTodoLists()
        let setting = Setting(name: "Everyday", frequency: .everyday)
        days.applySetting(setting)

        for list in days {
            switch list.weekDay {
            case calendar.weekdaySymbols[0],
                 calendar.weekdaySymbols[1],
                 calendar.weekdaySymbols[2],
                 calendar.weekdaySymbols[3],
                 calendar.weekdaySymbols[4],
                 calendar.weekdaySymbols[5],
                 calendar.weekdaySymbols[6]:
                XCTAssertEqual(list.todos.map { $0.text }, ["Everyday"])
            default:
                XCTAssertEqual(list.todos, [])
            }
        }
    }
}
