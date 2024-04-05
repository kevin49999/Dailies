//
//  TodoViewData.swift
//  TODOs
//
//  Created by Kevin Johnson on 1/26/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import UIKit

protocol TodoViewData {
    var text: String { get }
    var attributedText: NSAttributedString? { get }
}

extension Todo: TodoViewData {
    var attributedText: NSAttributedString? {
        let font = UIFont.systemFont(
            ofSize: 16,
            weight: .regular
        ).scaledFontforTextStyle(.body)
        if completed {
            let attributes: [NSAttributedString.Key : Any] = [
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
                NSAttributedString.Key.strikethroughColor: UIColor.secondaryLabel,
                NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel
            ]
            return NSAttributedString(string: text, attributes: attributes)
        }
        let attributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.label
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }
}

extension TodoList: TodoViewData {
    var text: String { weekDay }
    var attributedText: NSAttributedString? {
        let font = UIFont.systemFont(
            ofSize: 16,
            weight: .regular
        ).scaledFontforTextStyle(.body)
        let attributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.label
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }
}
