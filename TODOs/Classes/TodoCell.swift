//
//  TodoCell.swift
//  TODOs
//
//  Created by Kevin Johnson on 11/19/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit

class TodoCell: UITableViewCell {
    
    @IBOutlet weak private var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func configure(data: TodoViewData) {
        textView.text = data.text
    }
    
    private func setup() {
        textView.adjustsFontForContentSizeCategory = true
        textView.font = UIFont.systemFont(
            ofSize: 16,
            weight: .semibold
        ).scaledFontforTextStyle(.body)
    }
    
}
