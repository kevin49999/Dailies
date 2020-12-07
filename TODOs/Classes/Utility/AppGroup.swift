//
//  AppGroup.swift
//  
//
//  Created by Kevin Johnson on 12/6/20.
//

import Foundation

// https://useyourloaf.com/blog/sharing-data-with-a-widget/
enum AppGroup: String {
  case todos = "group.com.FRR.freetime"

    var containerURL: URL {
        switch self {
        case .todos:
            return FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: rawValue
            )!
        }
    }
}
