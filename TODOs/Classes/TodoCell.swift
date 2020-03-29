//
//  TodoCell.swift
//  TODOs
//
//  Created by Kevin Johnson on 11/19/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit

protocol TodoCellCellDelegate: class {
    func todoCell(_ cell: TodoCell, isEditing textView: UITextView)
    func todoCell(_ cell: TodoCell, didEndEditing text: String)
}

class TodoCell: UITableViewCell {

    weak var delegate: TodoCellCellDelegate?
    @IBOutlet weak private var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func configure(data: TodoViewData) {
        textView.text = data.text
    }
    
    private func setup() {
        textView.delegate = self
        textView.adjustsFontForContentSizeCategory = true
        textView.font = UIFont.systemFont(
            ofSize: 16,
            weight: .semibold
        ).scaledFontforTextStyle(.body)
    }

    private func reset() {
        textView.resignFirstResponder()
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
