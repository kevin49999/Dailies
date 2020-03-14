//
//  TodoListViewData.swift
//  TODOs
//
//  Created by Kevin Johnson on 2/15/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import Foundation

protocol TodoListViewData {
    var showAction: Bool { get }
    func titleCopy() -> String
}

extension TodoList: TodoListViewData {
    var showAction: Bool {
        switch classification {
        case .created:
            return true
        case .daysOfWeek:
            return false
        }
    }
    func titleCopy() -> String {
        switch classification {
        case .created:
            return name
        case .daysOfWeek:
            let isToday = dateCreated == .todayYearMonthDay()
            var dateString = DateFormatters.daysOfWeekNameDayMonth.string(
                from: dateCreated
            )

            // can be cleaner
            if isWeekend || isToday {
                dateString.insert(" ", at: dateString.startIndex)
            }
            if isWeekend {
                dateString.insert("🏝", at: dateString.startIndex)
            }
            if isToday {
                dateString.insert("🌠", at: dateString.startIndex)
            }
            return dateString
        }
    }
}
