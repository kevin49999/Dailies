//
//  TodoCell.swift
//  TODOs
//
//  Created by Kevin Johnson on 11/19/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit

protocol TodoCellDelegate: class {
    func todoCell(_ cell: TodoCell, isEditing textView: UITextView)
    func todoCell(_ cell: TodoCell, didEndEditing text: String)
}

class TodoCell: UITableViewCell {

    weak var delegate: TodoCellDelegate?
    @IBOutlet weak private var textView: DataTextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func configure(data: TodoViewData) {
        textView.attributedText = data.attributedText
    }
    
    private func setup() {
        textView.isEditable = false
        textView.delegate = self
        textView.isSelectable = true
        textView.adjustsFontForContentSizeCategory = true
    }
}

// MARK: - UITextViewDelegate

extension TodoCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if !textView.text.isEmpty {
            delegate?.todoCell(self, isEditing: textView)
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        textView.isEditable = false
        delegate?.todoCell(self, didEndEditing: textView.text)
    }
}

// MARK: - DataTextView

/// based on: https://stackoverflow.com/a/65721757
class DataTextView: UITextView {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touchPoint = touches.first?.location(in: self) else { fatalError() }
        let characterIndex = layoutManager.characterIndex(
            for: touchPoint,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )

        /// return for link if link at range or is last character
        if characterIndex < text.count - 1, textStorage.attribute(
            NSAttributedString.Key.link,
            at: characterIndex,
            effectiveRange: nil
        ) != nil {
            /// have to reset
            selectedTextRange = nil
            return
        } else {
            isEditable = true
            guard let position = closestPosition(to: touchPoint) else { fatalError() }
            guard let range: UITextRange = textRange(from: position, to: position) else { fatalError() }
            becomeFirstResponder()
            selectedTextRange = range
        }
    }
}
