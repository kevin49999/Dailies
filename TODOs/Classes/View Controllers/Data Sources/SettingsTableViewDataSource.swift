//
//  SettingsTableViewDataSource.swift
//  TODOs
//
//  Created by Kevin Johnson on 9/8/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import UIKit

typealias SettingsCellsDelegate = AddTodoCellDelegate & RecurringTodoCellDelegate

class SettingsTableViewDataSource: UITableViewDiffableDataSource<SettingsViewController.Section, Setting> {

    typealias Section = SettingsViewController.Section
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Setting>

    var settings: [Setting] = []

    convenience init(
        tableView: UITableView,
        settings: [Setting],
        cellDelegate: SettingsCellsDelegate? = nil
    ) {
        self.init(tableView: tableView, cellProvider: { [weak cellDelegate] tableView, indexPath, setting in
            if setting.name == "AddTodoCellHack" {
                let cell: AddTodoCell = tableView.dequeueReusableCell(for: indexPath)
                cell.separatorInset = .hideSeparator // hide last
                cell.delegate = cellDelegate
                return cell
            }
            let cell: RecurringTodoCell = tableView.dequeueReusableCell(for: indexPath)
            cell.delegate = cellDelegate
            cell.configure(data: setting)
            return cell
        })
        self.settings = settings
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if settings.count == indexPath.row {
            return false // AddTodoCell
        }
        return true
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if settings.count == indexPath.row {
            return false // AddTodoCell
        }
        return true
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Recurring 🔁"
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // not currently deleting from lists that may have added these recurring todos at some point
        let setting = settings.remove(at: indexPath.row)
        var current = snapshot()
        current.deleteItems([setting])
        apply(current, animatingDifferences: true)
    }
}

// MARK: - Helper

extension SettingsTableViewDataSource {
    func applySnapshot(animatingDifferences: Bool = true) {
        var new = Snapshot()
        new.appendSections([.recurring])
        var items = settings
        // TODO: Repeated hack from TodoListTableViewDataSource
        if let add = snapshot().itemIdentifiers(inSection: .recurring)
            .first(where: { $0.name == "AddTodoCellHack" }) {
            items.append(add)
        } else {
            items.append(.init(name: "AddTodoCellHack", frequency: .mondays))
        }
        new.appendItems(items, toSection: .recurring)
        apply(new, animatingDifferences: animatingDifferences)
    }
}
