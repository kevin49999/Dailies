//
//  TodoListTableViewDataSource.swift
//  TODOs
//
//  Created by Kevin Johnson on 5/29/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import UIKit

typealias TodoListCellsDelegate = AddTodoCellDelegate & TodoCellDelegate

enum TodoListCellModel: Hashable {
    case todo(Todo)
    case add(date: String)
}

class TodoListTableViewDataSource: UITableViewDiffableDataSource<TodoList, TodoListCellModel> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<TodoList, TodoListCellModel>
    weak var cellDelegate: TodoListCellsDelegate?
    var todoLists: [TodoList] = []
    
    convenience init(
        tableView: UITableView,
        todoLists: [TodoList],
        cellDelegate: TodoListCellsDelegate? = nil
    ) {
        self.init(tableView: tableView, cellProvider: { [weak cellDelegate] tableView, indexPath, model in
            switch model {
            case .todo(let todo):
                let cell: TodoCell = tableView.dequeueReusableCell(for: indexPath)
                cell.delegate = cellDelegate
                cell.configure(data: todo)
                return cell
            case .add:
                let cell: AddTodoCell = tableView.dequeueReusableCell(for: indexPath)
                cell.separatorInset = .hideSeparator
                cell.delegate = cellDelegate
                return cell
            }
        })
        self.todoLists = todoLists
        self.cellDelegate = cellDelegate
        self.defaultRowAnimation = .fade
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // sort of hack
        if indexPath.row >= todoLists[indexPath.section].visible.count {
            return false
        }
        return true
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // ""
        if indexPath.row >= todoLists[indexPath.section].visible.count {
            return false
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

// MARK: - Extensions

extension TodoListTableViewDataSource {
    func applySnapshot(animatingDifferences: Bool = true) {
        var new = Snapshot()
        for list in todoLists {
            new.appendSections([list])
            new.appendItems(list.visible.map { .todo($0) }, toSection: list)
            new.appendItems([.add(date: list.uniqueDay)], toSection: list)
        }
        apply(new, animatingDifferences: animatingDifferences)
    }

    func reload(_ todo: Todo) {
        var current = snapshot()
        current.reloadItems([.todo(todo)])
        apply(current, animatingDifferences: true)
    }

    func insert(_ todo: Todo, after: Todo) {
        var current = snapshot()
        current.insertItems([.todo(todo)], afterItem: .todo(after))
        apply(current, animatingDifferences: true)
    }

    func delete(_ todo: Todo) {
        var current = snapshot()
        current.deleteItems([.todo(todo)])
        apply(current, animatingDifferences: true)
    }
}
