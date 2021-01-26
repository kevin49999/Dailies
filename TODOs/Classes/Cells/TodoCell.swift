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
        textView.isEditable = false
        textView.delegate = self
        textView.adjustsFontForContentSizeCategory = true
    }

    private func reset() {
        textView.isEditable = false
        textView.resignFirstResponder()
    }

    @IBAction private func didTapTextView(_ sender: UIButton) {
        if !textView.isEditable {
            textView.isEditable = true
            textView.becomeFirstResponder()
        }
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
        reset()
    }
}
