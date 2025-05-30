//
//  UIAlertController+Extensions.swift
//  TODOs
//
//  Created by Kevin Johnson on 2/15/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import UIKit

// MARK: - UIAlertAction

extension UIAlertAction {
    static func cancel(_ handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction{
        return UIAlertAction(title: "Cancel", style: .cancel, handler: handler)
    }

    static func delete(_ handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction{
        return UIAlertAction(title: "Delete", style: .destructive, handler: handler)
    }

    static func ok(_ handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction{
        return UIAlertAction(title: "OK", style: .default, handler: handler)
    }
}

// MARK: - Utility

extension UIAlertController {
    func addActions(_ alerts: [UIAlertAction]) {
        for alert in alerts {
            addAction(alert)
        }
    }
}
