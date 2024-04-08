//
//  Setting.swift
//  TODOs
//
//  Created by Kevin Johnson on 9/10/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import Foundation

struct Setting: Codable, Identifiable, Hashable {
    enum CodingKeys: CodingKey {
        case id
        case name
        case frequency
    }

    // TODO: Make it OptionSet https://nshipster.com/optionset/
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
                return Calendar.autoupdatingCurrent.shortWeekdaySymbols[self.rawValue]
            case .weekends:
                return NSLocalizedString("Weekends", comment: "")
            case .weekdays:
                return NSLocalizedString("Weekdays", comment: "")
            case .everyday:
                return NSLocalizedString("Everday", comment: "")
            }
        }
    }
    // MARK: - Properties

    var id: UUID
    var name: String
    var frequency: Frequency

    init(
        id: UUID = UUID(),
        name: String,
        frequency: Frequency = .mondays
    ) {
        self.id = id
        self.name = name
        self.frequency = frequency
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let id = try? values.decode(UUID.self, forKey: .id) {
            self.id = id
        } else {
            /// new property as of 12/23 so need the fallback for decoding old Settings
            id = UUID()
        }
        name = try values.decode(String.self, forKey: .name)
        frequency = try values.decode(Frequency.self, forKey: .frequency)
    }

    static func saved() -> [Setting] {
        do {
            return try Cache.read(path: "settings")
        } catch {
            return []
        }
    }
}
