//
//  UITableViewCell+Extensions.swift
//  TODOs
//
//  Created by Kevin Johnson on 11/19/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.storyboardIdentifier, for: indexPath) as? T else {
            fatalError("Could not find cell with identifier: \(T.storyboardIdentifier)")
        }
        return cell
    }
    
    func register<T: UITableViewCell>(cell: T.Type) {
        register(UINib(nibName: T.storyboardIdentifier, bundle: nil), forCellReuseIdentifier: T.storyboardIdentifier)
    }
}
