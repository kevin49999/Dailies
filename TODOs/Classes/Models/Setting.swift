//
//  Setting.swift
//  TODOs
//
//  Created by Kevin Johnson on 9/10/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import Foundation

struct Setting: Codable {
    enum Frequency: Int, Codable, CaseIterable {
        case sundays = 0
        case mondays
        case tuesdays
        case wednesdays
        case thursdays
        case fridays
        case saturdays
        case weekends = 100
        case weekdays
        case everyday

        var description: String {
            switch self {
            case .sundays,
                 .mondays,
                 .tuesdays,
                 .wednesdays,
                 .thursdays,
                 .fridays,
                 .saturdays:
                return Calendar.current.shortWeekdaySymbols[self.rawValue]
            case .weekends:
                return NSLocalizedString("Weekends", comment: "")
            case .weekdays:
                return NSLocalizedString("Weekdays", comment: "")
            case .everyday:
                return NSLocalizedString("Everday", comment: "")
            }
        }
    }
    var name: String
    var frequency: Frequency

    init(name: String, frequency: Frequency = .mondays) {
        self.name = name
        self.frequency = frequency
    }


    static func saved() -> [Setting] {
        do {
            return try Cache.read(path: "settings")
        } catch {
            return []
        }
    }
}

extension Setting: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(frequency)
    }

    static func == (lhs: Setting, rhs: Setting) -> Bool {
        return lhs.name == rhs.name && lhs.frequency == rhs.frequency
    }
}
