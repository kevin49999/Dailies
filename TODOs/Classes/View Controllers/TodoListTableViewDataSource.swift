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
        self.init(tableView: tableView, cellProvider: { tableView, indexPath, todo in
            if todoLists[indexPath.section].visible.count == indexPath.row {
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
        todoLists[destinationIndexPath.section].todos.prettyPrint()
        todoLists[destinationIndexPath.section].incomplete.prettyPrint()
        applySnapshot(animatingDifferences: false)  // TODO: still not great
    }
}

extension TodoListTableViewDataSource {
    func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        for list in todoLists {
            snapshot.appendSections([list])
            var items = list.visible
            if items.count > 0 { items.prettyPrint() }
            items.append(.init(text: "AddTodoCellHacky"))
            snapshot.appendItems(items, toSection: list)
        }
        apply(snapshot, animatingDifferences: animatingDifferences)
    }

    func reload(_ todo: Todo) {
        var current = snapshot()
        current.reloadItems([todo])
        apply(current, animatingDifferences: true)
    }

    func delete(_ todo: Todo) {
        var current = snapshot()
        current.deleteItems([todo])
        apply(current, animatingDifferences: true)
    }
}
