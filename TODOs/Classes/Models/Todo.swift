//
//  Todo.swift
//  TODOs
//
//  Created by Kevin Johnson on 1/26/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import Foundation
import CloudKit

class Todo: Codable, Identifiable {
    enum CodingKeys: CodingKey {
        case id
        case text
        case completed
        case settingUUID
    }

    var id: UUID
    var text: String
    var completed: Bool
    var settingUUID: String?

    var isSetting: Bool { settingUUID != nil }

    init(
        id: UUID = UUID(),
        text: String,
        completed: Bool = false,
        settingUUID: String? = nil
    ) {
        self.id = id
        self.text = text
        self.completed = completed
        self.settingUUID = settingUUID
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let id = try? values.decode(UUID.self, forKey: .settingUUID) {
            self.id = id
        } else {
            id = UUID()
        }
        text = try values.decode(String.self, forKey: .text)
        completed = try values.decode(Bool.self, forKey: .completed)
        if let settingUUID = try? values.decode(String.self, forKey: .settingUUID) {
            self.settingUUID = settingUUID
        } else {
            settingUUID = nil
        }
    }

    init?(record: CKRecord) {
        guard let idString = record["id"] as? String,
              let id = UUID(uuidString: idString),
              let text = record["text"] as? String,
              let completed = record["completed"] as? Bool else { return nil }

        self.id = id
        self.text = text
        self.completed = completed
        self.settingUUID = record["settingUUID"] as? String ?? nil
    }
    
    func duplicate() -> Todo { .init(text: text, completed: completed) }
}

// MARK: - Hashable

extension Todo: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Todo, rhs: Todo) -> Bool {
        return lhs.id == rhs.id
    }
}
