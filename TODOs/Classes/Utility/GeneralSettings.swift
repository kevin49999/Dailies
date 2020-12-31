//
//  GeneralSettings.swift
//  TODOs
//
//  Created by Kevin Johnson on 12/30/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import Foundation

class GeneralSettings {

    enum Settings: String {
        case toggleHideCompleted = "toggle_hide_completed"
        case toggleRollover = "toggle_rollover"
    }

    static let shared = GeneralSettings()

    private let defaults: UserDefaults = .standard

    private init() { }

    var hideCompleted: Bool {
        if let hide = defaults.value(forKey: Settings.toggleHideCompleted.rawValue) as? Bool {
            return hide
        }
        return true
    }
    var rollover: Bool { defaults.bool(forKey: Settings.toggleRollover.rawValue) }

    func toggleHideCompleted(on: Bool) {
        // TODO: Should update all exising lists?
        defaults.set(on, forKey: Settings.toggleHideCompleted.rawValue)
    }

    func toggleRollover(on: Bool) {
        defaults.set(on, forKey: Settings.toggleRollover.rawValue)
    }
}
