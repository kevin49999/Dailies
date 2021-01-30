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
    @IBOutlet weak private var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func configure(data: TodoViewData) {
        textView.attributedText = data.attributedText
    }
    
    private func setup() {
        textView.isEditable = true
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
        delegate?.todoCell(self, didEndEditing: textView.text)
    }
}

// - https://stackoverflow.com/a/65721757, want to use for solution with data detection + editing
// not working yet
class DataTextView: UITextView {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        guard let touchPoint = touches.first?.location(in: self) else { fatalError() }

        let glyphIndex = self.layoutManager.glyphIndex(for: touchPoint, in: self.textContainer)
        let glyphRect = self.layoutManager.boundingRect(forGlyphRange: NSRange(location: glyphIndex, length: 1), in: self.textContainer)

        if glyphIndex < self.textStorage.length,
           glyphRect.contains(touchPoint),
           self.textStorage.attribute(NSAttributedString.Key.link, at: glyphIndex, effectiveRange: nil) != nil {
            // Then touchEnded on url
            return
        } else {
            self.isEditable = true

            // Retreive the insert point from touch.
            guard let position = self.closestPosition(to: touchPoint) else { fatalError() }
            guard let range: UITextRange = self.textRange(from: position, to: position) else { fatalError() }

            // You will want to make the text view enter editing mode by one tap, not two.
            self.becomeFirstResponder()

            // Set the insert point.
            self.selectedTextRange = range
        }
    }
}
