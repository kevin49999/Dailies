//
//  SettingsViewController.swift
//  TODOs
//
//  Created by Kevin Johnson on 9/4/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    enum Section {
        case recurring
    }

    // MARK: - Properties

    private lazy var dataSource: SettingsTableViewDataSource = {
        return SettingsTableViewDataSource(
            tableView: self.tableView,
            settings: Setting.saved(),
            cellDelegate: self
        )
    }()
    private var changingFreqIndex: Int?
    private var changingFrequencies: [Setting.Frequency] = []

    // MARK: - Deinit

    deinit {
        try? Cache.save(dataSource.settings, path: "settings")
        NotificationCenter.default.post(name: .init(rawValue: "SettingsChanged"), object: nil)
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(cell: RecurringTodoCell.self)
        tableView.register(cell: AddTodoCell.self)
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
            dataSource.settings[indexPath.row].name = text // TODO: Doesn't update current curring TODOs
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
        guard let index = changingFreqIndex else { preconditionFailure() }
        self.dataSource.settings[index].frequency = changingFrequencies[row] // TODO: ""
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.changingFreqIndex = nil
        self.changingFrequencies = []
        self.dataSource.applySnapshot(animatingDifferences: false)
    }
}
