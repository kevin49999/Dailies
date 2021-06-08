//
//  Date+Extensions.swift
//  TODOs
//
//  Created by Kevin Johnson on 2/5/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import Foundation

extension Date {
    /// calendar.compare.toGranularity(.day) should work, and is working in playground but still not getting what I want with below date objs
    /// " today 2021-01-16 08:00:00 +0000"
    /// "created 2021-01-16 05:00:00 +0000", still got .orderedAscending instead of .same for day comparison
    func isBefore(_ before: Date, calendar: Calendar = .current) -> Bool {
        let dMonth = calendar.component(.month, from: self)
        let dDay = calendar.component(.day, from: self)
        let dYear = calendar.component(.year, from: self)
        let tMonth = calendar.component(.month, from: before)
        let tDay = calendar.component(.day, from: before)
        let tYear = calendar.component(.year, from: before)
        /// year check
        if dYear < tYear {
            return true
        } else if dYear > tYear {
            return false
        }
        /// month, days in same year established
        if dMonth < tMonth {
            return true
        } else if dMonth > tMonth {
            return false
        }
        /// day, days in same month established
        if dDay < tDay {
            return true
        }
        return false
    }

    func byAddingDays(_ day: Int, calendar: Calendar = .current) -> Date {
        guard let n = Calendar.current.date(byAdding: .day, value: day, to: self) else {
            preconditionFailure()
        }
        return n
    }

    static func todayMonthDayYear(calendar: Calendar = .current) -> Date {
        let comp = calendar.dateComponents([.year, .month, .day], from: Date())
        return monthDayYearDate(month: comp.month!, day: comp.day!, year: comp.year!)
    }

    private static func monthDayYearDate(month: Int, day: Int, year: Int, calendar: Calendar = .current) -> Date {
        let comp = DateComponents(year: year, month: month, day: day)
        return calendar.date(from: comp)!
    }
}
