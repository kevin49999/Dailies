//
//  UIViewController+ChildControllers.swift
//  TODOs
//
//  Created by Kevin Johnson on 2/23/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import UIKit

extension UIViewController {
    func add(_ child: UIViewController, to contentView: UIView? = nil) {
        addChild(child)
        if let contentView = contentView {
            child.view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(child.view)
            NSLayoutConstraint.activate([
                child.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                child.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                child.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                child.view.topAnchor.constraint(equalTo: contentView.topAnchor)
            ])
        } else {
            view.addSubview(child.view)
        }
        child.didMove(toParent: self)
    }

    func remove() {
        guard parent != nil else {
            return
        }

        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
