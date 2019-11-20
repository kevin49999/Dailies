//
//  TodoCell.swift
//  TODOs
//
//  Created by Kevin Johnson on 11/19/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit

class TodoCell: UITableViewCell {
    
    @IBOutlet weak private var todoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        todoLabel.adjustsFontForContentSizeCategory = true
        todoLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold).scaledFontforTextStyle(.body)
    }
    
}

// TODO: ++AddItem Cell
