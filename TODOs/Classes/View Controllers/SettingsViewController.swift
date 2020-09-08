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

    struct Setting: Codable, Hashable {
        enum Frequency: String, Codable {
            case sundays
            case mondays
            case tuesdays
            case wednesdays
            case thursdays
            case fridays
            case saturdays
            case weekends
            case everyday

            var description: String {
                return "Mon."
            }
        }
        var name: String
        var frequency: Frequency

        init(name: String, frequency: Frequency = .mondays) {
            self.name = name
            self.frequency = frequency
        }
    }

    // MARK: - Properties

    lazy var dataSource: SettingsTableViewDataSource = {
        do {
            let settings: [Setting] = try Cache.read(path: "settings")
            return SettingsTableViewDataSource(
                tableView: self.tableView,
                settings: settings,
                cellDelegate: self
            )
        } catch {
            return SettingsTableViewDataSource(
                tableView: self.tableView,
                settings: [],
                cellDelegate: self
            )
        }
    }()

    // MARK: - Deinit

    deinit {
        // TODO: Update current weekly TODOs!
        try? Cache.save(dataSource.settings, path: "settings")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(cell: RecurringTodoCell.self)
        tableView.register(cell: AddTodoCell.self)
        tableView.dataSource = dataSource
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
            dataSource.settings[indexPath.row].name = text
        }
    }

    func recurringTodoCellDidTapFreq(_ cell: RecurringTodoCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            assertionFailure()
            return
        }
        let freq = dataSource.settings[indexPath.row].frequency
        print(freq)

        // TODO: Present picker for freq..
    }
}
