//
//  Undo.swift
//  TODOs
//
//  Created by Kevin Johnson on 6/1/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import UIKit

// s/o https://github.com/GitHawkApp/Squawk 🦅
class Undo {
    static let shared = Undo()

    private var active: UndoItem?

    private init() { }

    func show(title: String, completion: @escaping ((Bool) -> Void)) {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
            let topMostChild = window.rootViewController?.topMostChild,
            let presenterView = topMostChild.view else {
            preconditionFailure()
        }

        self.active?.dismiss(undo: false)
        let item = UndoItem(title: title, presenterView: presenterView) { undo in
            completion(undo)
        }
        self.active = item
    }
}

fileprivate extension UIViewController {
    var topMostChild: UIViewController? {
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostChild
        } else if let nav = self as? UINavigationController {
            return nav.topViewController?.topMostChild
        } else if let split = self as? UISplitViewController {
            return split.viewControllers.last?.topMostChild
        } else if let presented = presentedViewController {
            return presented.topMostChild
        }
        return self
    }
}
