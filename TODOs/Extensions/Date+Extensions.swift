//
//  Date+Extensions.swift
//  TODOs
//
//  Created by Kevin Johnson on 2/5/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import Foundation

extension Date {
    func byAddingDays(_ day: Int, calendar: Calendar = .current) -> Date {
        guard let n = calendar.date(byAdding: .day, value: day, to: self) else {
            preconditionFailure()
        }
        return n
    }
}
