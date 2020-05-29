//
//  TodoListTableViewDataSource.swift
//  TODOs
//
//  Created by Kevin Johnson on 5/29/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import UIKit

typealias TodoListCellsDelegate = AddTodoCellDelegate & TodoCellDelegate

class TodoListTableViewDataSource: NSObject, UITableViewDataSource {

    unowned let cellDelegate: TodoListCellsDelegate
    private var todoLists: [TodoList]

    init(todoLists: [TodoList], cellDelegate: TodoListCellsDelegate) {
        self.todoLists = todoLists
        self.cellDelegate = cellDelegate
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return todoLists.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoLists[section].visible.count + 1 // for AddTodoCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let list = todoLists[indexPath.section]
        if list.visible.count == indexPath.row {
            let cell: AddTodoCell = tableView.dequeueReusableCell(for: indexPath)
            if indexPath.section == todoLists.count - 1 {
                cell.separatorInset = .hideSeparator // hide last
            }
            cell.delegate = cellDelegate
            return cell
        }
        let cell: TodoCell = tableView.dequeueReusableCell(for: indexPath)
        cell.delegate = cellDelegate
        cell.configure(data: list.visible[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if todoLists[indexPath.section].visible.count == indexPath.row {
            return false // AddTodoCell
        }
        return true
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if todoLists[indexPath.section].visible.count == indexPath.row {
            return false // AddTodoCell
        }
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let result = todoLists[sourceIndexPath.section].move(
            sIndex: sourceIndexPath.row,
            destination: todoLists[destinationIndexPath.section],
            dIndex: destinationIndexPath.row
        )
        switch result {
        case .completedMovedToShowComplete?:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.todoLists[destinationIndexPath.section].incomplete.remove(at: destinationIndexPath.row)
                tableView.deleteRows(at: [destinationIndexPath], with: .automatic)
            })
        default:
            break
        }
        todoLists[destinationIndexPath.section].todos.prettyPrint()
        todoLists[destinationIndexPath.section].incomplete.prettyPrint()
    }
}
