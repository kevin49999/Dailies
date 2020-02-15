//
//  Date+Extensions.swift
//  TODOs
//
//  Created by Kevin Johnson on 2/5/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import Foundation

extension Date {
    static func from(year: Int, month: Int, day: Int, calendar: Calendar = .current) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        guard let date = calendar.date(from: components) else {
            preconditionFailure("Invalid Date")
        }
        return date
    }

    static func todayYearMonthDay(calendar: Calendar = .current) -> Date {
        let today = Date()
        return Date.from(
            year: calendar.component(.year, from: today),
            month: calendar.component(.month, from: today),
            day: calendar.component(.day, from: today)
        )
    }
}
