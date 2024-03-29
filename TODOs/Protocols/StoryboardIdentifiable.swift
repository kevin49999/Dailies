//
//  StoryboardIdentifiable.swift
//  TODOs
//
//  Created by Kevin Johnson on 11/19/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit

protocol StoryboardIdentifiable {
    static var storyboardIdentifier: String { get }
}

extension StoryboardIdentifiable where Self: UIView {
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
}

extension UIView: StoryboardIdentifiable { }
