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

    // TODO: !
    func saveLists() {

    }
}
