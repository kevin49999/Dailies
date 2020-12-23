//
//  Todo.swift
//  TODOs
//
//  Created by Kevin Johnson on 1/26/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import Foundation

class Todo: Codable {

    enum CodingKeys: CodingKey {
        case text
        case completed
        case settingUUID
    }

    var text: String
    var completed: Bool
    var settingUUID: String?

    init(
        text: String,
        completed: Bool = false,
        settingUUID: String? = nil
    ) {
        self.text = text
        self.completed = completed
        self.settingUUID = settingUUID
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        text = try values.decode(String.self, forKey: .text)
        completed = try values.decode(Bool.self, forKey: .completed)
        if let id = try? values.decode(String.self, forKey: .settingUUID) {
            settingUUID = id
        } else {
            /// new property as of 12/23 so need the fallback for decoding old TODOs
            settingUUID = nil
        }
    }

    func duplicate() -> Todo {
        return .init(text: self.text, completed: self.completed)
    }
}

extension Todo: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
        hasher.combine(completed)
    }

    static func == (lhs: Todo, rhs: Todo) -> Bool {
        return lhs.text == rhs.text && lhs.completed == rhs.completed
    }
}
