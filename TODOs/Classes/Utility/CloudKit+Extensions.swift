//
//  CloudKit+Extensions.swift
//  TODOs
//
//  Created by Kevin Johnson on 8/28/22.
//  Copyright © 2022 Kevin Johnson. All rights reserved.
//

// mv?
import Foundation
import CloudKit

class CloudDB {
    let container: CKContainer
    let publicDB: CKDatabase
    let privateDB: CKDatabase

    static var shared = CloudDB()

    init() {
        container = CKContainer.default()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
    }

    func lists() async throws -> [TodoList] {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "TodoList", predicate: predicate)
        let records = try await publicDB.perform(query, inZoneWith: CKRecordZone.default().zoneID)

        var result = [TodoList]()
        for record in records {
            guard let list = TodoList(record: record, database: self.publicDB) else {
                continue
            }
            result.append(list)
            guard let todosReferences = record["todos"] as? [CKRecord.Reference] else {
                continue
            }

            let ids = todosReferences.map { $0.recordID }
            publicDB.fetch(withRecordIDs: ids) { derp in
                switch derp {
                case .success(let der):
                    // the order THO!
                    let todos: [Todo] = der.values.compactMap {
                        switch $0 {
                        case .success(let record):
                            return .init(record: record)
                        case .failure:
                            return nil
                        }
                    }
                    list.todos = todos
                    // not async tho.. have 2 return
                case .failure(let err):
                    print(err)
                }
            }
        }
        return result
    }
}
