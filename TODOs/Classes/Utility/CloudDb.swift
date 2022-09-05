//
//  CloudDb.swift
//  TODOs
//
//  Created by Kevin Johnson on 8/28/22.
//  Copyright © 2022 Kevin Johnson. All rights reserved.
//

import Foundation
import CloudKit

class CloudDb {
    private let container: CKContainer
    private let privateDb: CKDatabase

    static var shared = CloudDb()

    init() {
        container = .default()
        privateDb = container.privateCloudDatabase
    }

    /// fetch if all user lists are empty!
    /// provide popup w/ options to restore with iCloud
    /// could be a simple UIAlert like, "We found lists in ICloud! do you want to restore?"
    func lists() async throws -> [TodoList] {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "TodoList", predicate: predicate)
        let records = try await privateDb.records(matching: query)

        var result = [TodoList]()
        for matchResult in records.matchResults {
            guard case .success(let record) = matchResult.1 else {
                continue
            }
            guard let list = TodoList(record: record) else {
                continue
            }
            // add list
            result.append(list)

            // find its todos
            guard let todosReferences = record["todos"] as? [CKRecord.Reference] else {
                continue
            }

            let ids = todosReferences.map { $0.recordID }
            let todoRecords = try await privateDb.records(for: ids)
            list.todos = todoRecords.compactMap {
                guard case .success(let record) = $0.value else {
                    return nil
                }
                return .init(record: record)
            }
        }
        return result
    }

    func saveLists(_ lists: [TodoList]) async throws {
        var records: [CKRecord] = []
        for list in lists {
            let record: CKRecord
            if let recordName = list.recordName {
                record = CKRecord(recordType: "TodoList", recordID: .init(recordName: recordName))
            } else {
                record = CKRecord(recordType: "TodoList")
                list.recordName = record.recordID.recordName
            }
            print(record.recordID)
            record["classification"] = list.classification.rawValue
            record["dateCreated"] = list.dateCreated
            record["name"] = list.name
            // don't save TODOs..?
            record["showCompleted"] = list.showCompleted
            records.append(record)
        }
        _ = try await privateDb.modifyRecords(saving: records, deleting: [])
    }

    func deleteList(_ list: TodoList) async throws {
        guard let recordName = list.recordName else {
            return
        }
        try await privateDb.deleteRecord(withID: CKRecord.ID(recordName: recordName))

        // TODO: delete all TODOs with that relationship!
    }
}
