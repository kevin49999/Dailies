//
//  RecurringTodoCell.swift
//  TODOs
//
//  Created by Kevin Johnson on 9/8/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import UIKit

protocol RecurringTodoCellDelegate: AnyObject {
    func recurringTodoCell(_ cell: RecurringTodoCell, isEditing textView: UITextView)
    func recurringTodoCell(_ cell: RecurringTodoCell, didEndEditing text: String)
    func recurringTodoCellDidTapFreq(_ cell: RecurringTodoCell)
}

class RecurringTodoCell: UITableViewCell {
    weak var delegate: RecurringTodoCellDelegate?
    
    @IBOutlet weak private var textView: UITextView!
    @IBOutlet weak private var frequencyButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func configure(data: Setting) {
        textView.text = data.name
        frequencyButton.setTitle(data.frequency.description, for: .normal)
    }

    private func setup() {
        textView.delegate = self
        textView.font = UIFont.systemFont(
            ofSize: 16,
            weight: .regular
        ).scaledFontforTextStyle(.body)
        textView.adjustsFontForContentSizeCategory = true
        frequencyButton.setTitleColor(.systemGreen, for: .normal)
        frequencyButton.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.20)
        frequencyButton.layer.cornerRadius = 6.0
    }

    private func reset() {
        textView.resignFirstResponder()
    }

    @IBAction private func didTapFreqButton(_ sender: UIButton) {
        delegate?.recurringTodoCellDidTapFreq(self)
    }
}

// MARK: - UITextViewDelegate

extension RecurringTodoCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if !textView.text.isEmpty {
            delegate?.recurringTodoCell(self, isEditing: textView)
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.recurringTodoCell(self, didEndEditing: textView.text)
        reset()
    }
}
