//
//  SettingsViewController.swift
//  TODOs
//
//  Created by Kevin Johnson on 9/4/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    enum Section: Int {
        case toggles = 0
        case recurring
    }

    // MARK: - Properties

    private lazy var dataSource: SettingsTableViewDataSource = {
        return SettingsTableViewDataSource(
            tableView: self.tableView,
            settings: initial,
            cellDelegate: self
        )
    }()
    private var initial = Setting.saved()
    private var changingFreqIndex: Int?
    private var changingFrequencies: [Setting.Frequency] = []

    // MARK: - Deinit

    deinit {
        if initial != dataSource.settings {
            try? Cache.save(dataSource.settings, path: "settings")
            NotificationCenter.default.post(name: .init(rawValue: "SettingsChanged"), object: nil)
        }
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(cell: RecurringTodoCell.self)
        tableView.register(cell: AddTodoCell.self)
        tableView.register(cell: SettingCell.self)
        tableView.estimatedRowHeight = 140
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 130
        dataSource.applySnapshot(animatingDifferences: false)
    }
}

// MARK: - AddTodoCellDelegate

extension SettingsViewController: AddTodoCellDelegate {
    func addTodoCell(_ cell: AddTodoCell, isEditing textView: UITextView) {
        tableView.resize(for: textView)
    }

    func addTodoCell(_ cell: AddTodoCell, didEndEditing text: String) {
        dataSource.settings.append(.init(name: text))
        dataSource.applySnapshot()
    }
}

// MARK: RecurringTodoCellDelegate

extension SettingsViewController: RecurringTodoCellDelegate {
    func recurringTodoCell(_ cell: RecurringTodoCell, isEditing textView: UITextView) {
        tableView.resize(for: textView)
    }

    func recurringTodoCell(_ cell: RecurringTodoCell, didEndEditing text: String) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            assertionFailure()
            return
        }
        if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            dataSource.settings[indexPath.row].name = text // TODO: Doesn't update current recurring TODOs
        }
    }

    func recurringTodoCellDidTapFreq(_ cell: RecurringTodoCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            assertionFailure()
            return
        }
        self.changingFreqIndex = indexPath.row
        var mFrequencies = Setting.Frequency.allCases
        let initial = self.dataSource.settings[indexPath.row].frequency
        mFrequencies.removeAll(where: { $0 == initial })
        mFrequencies.insert(initial, at: 0)
        self.changingFrequencies = mFrequencies
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        let dummy = UITextField(frame: .zero)
        dummy.delegate = self
        view.addSubview(dummy)
        dummy.inputView = picker
        dummy.becomeFirstResponder()
    }
}

// MARK: - SettingsCellsDelegate

extension SettingsViewController: SettingCellDelegate {
    func settingCell(_ cell: SettingCell, didToggle on: Bool) {
        switch tableView.indexPath(for: cell)?.row {
        case 0:
            GeneralSettings.shared.toggleHideCompleted(on: on)
        case 1:
            GeneralSettings.shared.toggleRollover(on: on)
        default:
            preconditionFailure()
        }
    }
}

// MARK: - Picker

extension SettingsViewController: UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Setting.Frequency.allCases.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard changingFreqIndex != nil else { preconditionFailure() }
        return changingFrequencies[row].description
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let index = changingFreqIndex else { return }
        self.dataSource.settings[index].frequency = changingFrequencies[row] // TODO: don't allow the duplicate if it makes it duplicate
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.changingFreqIndex = nil
        self.changingFrequencies = []
        self.dataSource.applySnapshot(animatingDifferences: false)
    }
}
