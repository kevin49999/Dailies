//
//  Cache.swift
//  TODOs
//
//  Created by Kevin Johnson on 2/2/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import Foundation

struct Cache {
    static func save<T: Encodable>(_ object: T, path: String, fileManager: FileManager = .default) throws {
        let folderURLs = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )

        let fileURL = folderURLs[0].appendingPathComponent(path + ".cache")
        let data = try JSONEncoder().encode(object)
        try data.write(to: fileURL)
    }

    static func read<T: Decodable>(path: String, fileManager: FileManager = .default) throws -> T {
        let folderURLs = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )

        let fileURL = folderURLs[0].appendingPathComponent(path + ".cache")
        let data = try Data(contentsOf: fileURL)
        let objects = try JSONDecoder().decode(T.self, from: data)
        return objects
    }
}
