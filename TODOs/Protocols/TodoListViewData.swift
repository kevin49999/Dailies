//
//  TodoListViewData.swift
//  TODOs
//
//  Created by Kevin Johnson on 2/15/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import Foundation

protocol TodoListViewData {
    var showTrash: Bool { get }
    func titleCopy() -> String
}

extension TodoList: TodoListViewData {
    var showTrash: Bool {
        switch classification {
        case .created:
            return true
        case .dayOfWeek:
            return false
        }
    }
    func titleCopy() -> String {
        switch classification {
        case .created:
            return name
        case .dayOfWeek:
            let isToday = dateCreated == .todayYearMonthDay()
            let dateString = DateFormatters.dayOfWeekNameDayMonth.string(
                from: dateCreated
            )
            if isToday {
                return "🌠 \(dateString)"
            }
            return dateString
        }
    }
}

