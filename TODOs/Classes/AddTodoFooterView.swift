//
//  AddTodoFooterView.swift
//  TODOs
//
//  Created by Kevin Johnson on 1/26/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import UIKit

protocol AddTodoFooterViewDelegate: class {
    func addTodoFooterView(_ view: AddTodoFooterView, isEditing textView: UITextView, section: Int)
    func addTodoFooterView(_ view: AddTodoFooterView, didEndEditing text: String, section: Int)
}

class AddTodoFooterView: UIView {

    var section: Int = 0
    weak var delegate: AddTodoFooterViewDelegate?
    @IBOutlet weak private var textView: UITextView!
    @IBOutlet weak private var placeholderTextView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func setup() {
        textView.delegate = self
        textView.adjustsFontForContentSizeCategory = true
        textView.font = UIFont.systemFont(
            ofSize: 16,
            weight: .semibold
        ).scaledFontforTextStyle(.body)
        placeholderTextView.adjustsFontForContentSizeCategory = true
        placeholderTextView.font = UIFont.systemFont(
            ofSize: 16,
            weight: .semibold
        ).scaledFontforTextStyle(.body)
    }

    private func reset() {
        textView.text = nil
        textView.resignFirstResponder()
        placeholderTextView.isHidden = false
    }
}

// MARK: - UITextViewDelegate

extension AddTodoFooterView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderTextView.isHidden = !textView.text.isEmpty
        if !textView.text.isEmpty {
            delegate?.addTodoFooterView(self, isEditing: textView, section: section)
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !text.isEmpty {
            delegate?.addTodoFooterView(self, didEndEditing: textView.text, section: section)
            reset()
        }
    }
}
