//
//  SettingCell.swift
//  TODOs
//
//  Created by Kevin Johnson on 12/23/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import UIKit

protocol SettingCellDelegate: class {
    func settingCell(_ cell: SettingCell, didToggle on: Bool)
}

class SettingCell: UITableViewCell {

    weak var delegate: SettingCellDelegate?

    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var toggleSwitch: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func configure(title: String, on: Bool) {
        self.titleLabel.text = title
        self.toggleSwitch.isOn = on
    }

    private func setup() {
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.font = UIFont.systemFont(
            ofSize: 16,
            weight: .regular
        ).scaledFontforTextStyle(.body)
    }

    @IBAction private func didToggleOnOff(_ sender: UISwitch) {
        delegate?.settingCell(self, didToggle: sender.isOn)
    }
}
