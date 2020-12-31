//
//  SettingsTableViewDataSource.swift
//  TODOs
//
//  Created by Kevin Johnson on 9/8/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import UIKit

typealias SettingsCellsDelegate = AddTodoCellDelegate & RecurringTodoCellDelegate & SettingCellDelegate

class SettingsTableViewDataSource: UITableViewDiffableDataSource<SettingsViewController.Section, SettingsTableViewDataSource.Model> {
    enum Model: Hashable {
        case toggle(ToggleSetting)
        case recurring(Setting)
    }

    typealias Section = SettingsViewController.Section
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Model>

    var settings: [Setting] = []

    convenience init(
        tableView: UITableView,
        settings: [Setting],
        cellDelegate: SettingsCellsDelegate? = nil
    ) {
        self.init(tableView: tableView, cellProvider: { [weak cellDelegate] tableView, indexPath, recurring in
            switch recurring {
            case .recurring(let recurring):
                if recurring.name == "AddTodoCellHack" {
                    let cell: AddTodoCell = tableView.dequeueReusableCell(for: indexPath)
                    cell.separatorInset = .hideSeparator // hide last
                    cell.delegate = cellDelegate
                    return cell
                }
                let cell: RecurringTodoCell = tableView.dequeueReusableCell(for: indexPath)
                cell.delegate = cellDelegate
                cell.configure(data: recurring)
                return cell
            case .toggle(let toggle):
                let cell: SettingCell = tableView.dequeueReusableCell(for: indexPath)
                cell.configure(title: toggle.name, on: toggle.isOn)
                cell.delegate = cellDelegate
                return cell
            }
        })
        self.settings = settings
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let s = Section(rawValue: indexPath.section) else {
            preconditionFailure()
        }
        switch s {
        case .toggles:
            return false
        case .recurring:
            if settings.count == indexPath.row {
                return false // AddTodoCell
            }
            return true
        }
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // TODO: Could enable, and update lists based on order in settings 🤔
        if settings.count == indexPath.row {
            return false // AddTodoCell
        }
        return true
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let s = Section(rawValue: section) else {
            preconditionFailure()
        }
        switch s {
        case .toggles:
            return "General"
        case .recurring:
            return "Recurring"
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let setting = settings.remove(at: indexPath.row)
        var current = snapshot()
        current.deleteItems([.recurring(setting)])
        apply(current, animatingDifferences: true)
    }
}

// MARK: - Helper

extension SettingsTableViewDataSource {
    func applySnapshot(animatingDifferences: Bool = true) {
        var new = Snapshot()
        new.appendSections([.toggles])
        new.appendItems(
            [.toggle(.init(name: "New Lists Hide Completed", isOn: GeneralSettings.shared.hideCompleted)),
             .toggle(.init(name: "Rollover Incomplete to Next Day", isOn: GeneralSettings.shared.rollover))
            ],
            toSection: .toggles
        )
        new.appendSections([.recurring])
        var items = settings.map { Model.recurring($0) }
        /// Repeated hack from TodoListTableViewDataSource
        let current = snapshot()
        if current.indexOfSection(.recurring) != nil,
           let add = current.itemIdentifiers(inSection: .recurring).first(where: {
            switch $0 {
            case .recurring(let setting):
                return setting.name == "AddTodoCellHack"
            case .toggle(_):
                return false // not doing in section
            }
           }) {
            items.append(add)
        } else {
            items.append(Model.recurring(.init(name: "AddTodoCellHack", frequency: .mondays)))
        }
        new.appendItems(items, toSection: .recurring)
        apply(new, animatingDifferences: animatingDifferences)
    }
}
