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
        formatter.dateFormat = "EEEE M/dd"
        return formatter
    }()
}
