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

    // TODO: NEXTTTT, can update on 1 simulator, then launch on reset/empty simulator (sign into icloud though)
    func lists() async throws -> (daysOfWeek: [TodoList], created: [TodoList]) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "TodoList", predicate: predicate)
        let records = try await privateDb.records(matching: query)

        var daysOfWeek = [TodoList]()
        var created = [TodoList]()
        for matchResult in records.matchResults {
            guard case .success(let record) = matchResult.1 else {
                continue
            }
            guard let list = TodoList(record: record) else {
                continue
            }
            switch list.classification {
            case .created:
                created.append(list)
            case .daysOfWeek:
                daysOfWeek.append(list)
            }
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
        // TODO: days of week will be in order, how to order created
        // TODO: how to order todos on EACH list




        return (daysOfWeek, created)
    }

    func saveLists(_ lists: [TodoList]) async throws {
        var records: [CKRecord] = []
        for list in lists {
            let listRecord: CKRecord
            if let recordName = list.recordName {
                listRecord = CKRecord(recordType: "TodoList", recordID: .init(recordName: recordName))
            } else {
                listRecord = CKRecord(recordType: "TodoList")
                list.recordName = listRecord.recordID.recordName
            }
            listRecord["classification"] = list.classification.rawValue
            listRecord["dateCreated"] = list.dateCreated
            listRecord["name"] = list.name
            for todo in list.todos {
                let todoRecord: CKRecord
                if let recordName = todo.recordName {
                    todoRecord = CKRecord(recordType: "Todo", recordID: .init(recordName: recordName))
                } else {
                    todoRecord = CKRecord(recordType: "Todo")
                    todo.recordName = todoRecord.recordID.recordName
                }
                todoRecord["id"] = todo.id.uuidString
                todoRecord["text"] = todo.text
                todoRecord["completed"] = todo.completed
                todoRecord["settingUUID"] = todo.settingUUID
                records.append(todoRecord)
            }
            listRecord["showCompleted"] = list.showCompleted
            records.append(listRecord)
        }
        _ = try await privateDb.modifyRecords(saving: records, deleting: [])
    }

    // TODO: TEST!
    func deleteList(_ list: TodoList) async throws {
        var deleting: [CKRecord.ID] = []
        guard let recordName = list.recordName else {
            return
        }
        deleting.append(.init(recordName: recordName))
        for todo in list.todos {
            guard let recordName = todo.recordName else { continue }
            deleting.append(.init(recordName: recordName))
        }
        _ = try await privateDb.modifyRecords(saving: [], deleting: deleting)
    }
}
