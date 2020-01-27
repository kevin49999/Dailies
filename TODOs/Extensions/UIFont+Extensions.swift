//
//  UIFont+Extensions.swift
//  TODOs
//
//  Created by Kevin Johnson on 11/19/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit

extension UIFont {
    func scaledFontforTextStyle(_ textStyle: UIFont.TextStyle) -> UIFont {
        return textStyle.fontMetrics.scaledFont(for: self)
    }
}

extension UIFont.TextStyle {
    var fontMetrics: UIFontMetrics {
        return UIFontMetrics(forTextStyle: self)
    }
}
