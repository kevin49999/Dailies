//
//  TodoListTableViewDataSource.swift
//  TODOs
//
//  Created by Kevin Johnson on 5/29/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import UIKit

typealias TodoListCellsDelegate = AddTodoCellDelegate & TodoCellDelegate

class TodoListTableViewDataSource: UITableViewDiffableDataSource<TodoList, Todo> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<TodoList, Todo>
    weak var cellDelegate: TodoListCellsDelegate?
    var todoLists: [TodoList] = []
    
    convenience init(
        tableView: UITableView,
        todoLists: [TodoList],
        cellDelegate: TodoListCellsDelegate? = nil
    ) {
        self.init(tableView: tableView, cellProvider: { [weak cellDelegate] tableView, indexPath, todo in
            if todo.text == "AddTodoCellHack" {
                let cell: AddTodoCell = tableView.dequeueReusableCell(for: indexPath)
                if indexPath.section == todoLists.count - 1 {
                    cell.separatorInset = .hideSeparator // hide last
                }
                cell.delegate = cellDelegate
                return cell
            }
            let cell: TodoCell = tableView.dequeueReusableCell(for: indexPath)
            cell.delegate = cellDelegate
            cell.configure(data: todo)
            return cell
        })
        self.todoLists = todoLists
        self.cellDelegate = cellDelegate
        self.defaultRowAnimation = .fade
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if todoLists[indexPath.section].visible.count == indexPath.row {
            return false // AddTodoCell
        }
        return true
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if todoLists[indexPath.section].visible.count == indexPath.row {
            return false // AddTodoCell
        }
        return true
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let result = todoLists[sourceIndexPath.section].move(
            sIndex: sourceIndexPath.row,
            destination: todoLists[destinationIndexPath.section],
            dIndex: destinationIndexPath.row
        )
        switch result {
        case .completedMovedToShowComplete?:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.todoLists[destinationIndexPath.section].incomplete.remove(at: destinationIndexPath.row)
                self.applySnapshot()
            })
        default:
            break
        }
        applySnapshot()
    }
}

extension TodoListTableViewDataSource {
    func applySnapshot(animatingDifferences: Bool = true) {
        var new = Snapshot()
        for list in todoLists {
            new.appendSections([list])
            var items = list.visible
            // TODO: Fix, bad hack >:[ or is it good?
            let current = snapshot()
            if current.indexOfSection(list) != nil,
               let add = current.itemIdentifiers(inSection: list).first(where: { $0.text == "AddTodoCellHack" }) {
                items.append(add)
            } else {
                items.append(.init(text: "AddTodoCellHack", completed: false))
            }
            // TODO: hacky again
            // new.appendItems(items, toSection: list)
            for item in items where new.sectionIdentifier(containingItem: item) == nil {
                new.appendItems([item], toSection: list)
            }
        }
        apply(new, animatingDifferences: animatingDifferences)
    }

    func reload(_ todo: Todo) {
        var current = snapshot()
        current.reloadItems([todo])
        apply(current, animatingDifferences: true)
    }

    func insert(_ todo: Todo, after: Todo) {
        var current = snapshot()
        current.insertItems([todo], afterItem: after)
        apply(current, animatingDifferences: true)
    }

    func delete(_ todo: Todo) {
        var current = snapshot()
        current.deleteItems([todo])
        apply(current, animatingDifferences: true)
    }
}
