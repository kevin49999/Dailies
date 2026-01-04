//
//  AddTodoCell.swift
//  TODOs
//
//  Created by Kevin Johnson on 1/26/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import UIKit

protocol AddTodoCellDelegate: AnyObject {
    func addTodoCell(_ cell: AddTodoCell, isEditing textView: UITextView)
    func addTodoCell(_ cell: AddTodoCell, didEndEditing textView: UITextView)
}

class AddTodoCell: UITableViewCell {
    weak var delegate: AddTodoCellDelegate?
    @IBOutlet weak private var textView: UITextView!
    @IBOutlet weak private var placeholderTextView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func reset() {
        textView.text = nil
        textView.resignFirstResponder()
        placeholderTextView.isHidden = false
    }

    private func setup() {
        textView.delegate = self
        textView.adjustsFontForContentSizeCategory = true
        textView.font = UIFont.systemFont(
            ofSize: 16,
            weight: .regular
        ).scaledFontforTextStyle(.body)
        placeholderTextView.adjustsFontForContentSizeCategory = true
        placeholderTextView.font = UIFont.systemFont(
            ofSize: 16,
            weight: .medium
        ).scaledFontforTextStyle(.body)
        
        let bar = UIToolbar()
        let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(resetTapped))
        bar.items = [done] // spacer to push over
        bar.sizeToFit()
        textView.inputAccessoryView = bar
    }
    
    @objc func resetTapped() {
        textView.resignFirstResponder()
    }
}

// MARK: - UITextViewDelegate

extension AddTodoCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderTextView.isHidden = !textView.text.isEmpty
        if !textView.text.isEmpty {
            delegate?.addTodoCell(self, isEditing: textView)
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n", !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty  {
            delegate?.addTodoCell(self, didEndEditing: textView)
            return false
        }
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = ""
            placeholderTextView.isHidden = false
        } else {
            delegate?.addTodoCell(self, didEndEditing: textView)
        }
    }
}
