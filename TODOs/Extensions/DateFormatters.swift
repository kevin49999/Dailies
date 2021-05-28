//
//  DateFormatters.swift
//  TODOs
//
//  Created by Kevin Johnson on 2/15/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import Foundation

struct DateFormatters {
    static let daysOfWeekNameDayMonth: DateFormatter = {
        let formatter = DateFormatter()
        // don't like the comma after US days of week, but this is more correct:
        // https://www.andyibanez.com/posts/formatting-notes-and-gotchas/
        // could combine day of week + month/date? 🤔
        formatter.setLocalizedDateFormatFromTemplate("EEEE M/dd")
        return formatter
    }()

    static let dayOfWeek: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEEE")
        return formatter
    }()
}
