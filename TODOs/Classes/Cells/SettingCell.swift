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

    weak var delegate: SettingCell?

    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var toggleSwitch: UISwitch!

    func configure(title: String, on: Bool) {
        self.titleLabel.text = title
        self.toggleSwitch.isOn = on
    }
}
