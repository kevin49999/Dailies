//
//  TodoListViewData.swift
//  TODOs
//
//  Created by Kevin Johnson on 2/15/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import Foundation

protocol TodoListViewData {
    func titleCopy() -> String
}

extension TodoList: TodoListViewData {
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

