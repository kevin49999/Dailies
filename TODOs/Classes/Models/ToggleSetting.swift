//
//  ToggleSetting.swift
//  TODOs
//
//  Created by Kevin Johnson on 12/30/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import Foundation

class ToggleSetting {
    let name: String
    var isOn: Bool

    init(name: String, isOn: Bool) {
        self.name = name
        self.isOn = isOn
    }
}

// MARK: - Hashable

extension ToggleSetting: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(isOn)
    }

    static func == (lhs: ToggleSetting, rhs: ToggleSetting) -> Bool {
        return lhs.name == rhs.name && lhs.isOn == rhs.isOn
    }
}
