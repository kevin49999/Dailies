//
//  ViewController.swift
//  TODOs
//
//  Created by Kevin Johnson on 11/19/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit

// TODO: UITableViewDiffableDataSource, ..

class TodoViewController: UIViewController {

    // MARK: - Properties
    // the custom ones, then 7 for the days
    var todoLists: [TodoList] = [
        TodoList(
            name: "Projects",
            todos: [Todo(text: "New App"),
                    Todo(text: "Automate Thing"),
                    Todo(text: "Derp")]
        ),
        TodoList(
            name: "Finance",
            todos: [Todo(text: "Upgrade Credit Card"),
                    Todo(text: "Cancel Old Bank"),
                    Todo(text: "$")]
        ),
        TodoList(
            name: "Misc.",
            todos: [Todo(text: "Get New Plant"),
                    Todo(text: "Do That Thing"),
                    Todo(text: "Nice Thing")]
        )
    ]

    @IBOutlet weak var tableView: UITableView!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(cell: TodoCell.self)
        tableView.register(cell: AddTodoCell.self)
        tableView.estimatedRowHeight = 250
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
    }

    // MARK: - IBAction

    // TODO: add list bar button item!
}

// MARK: - UITableViewDataSource

extension TodoViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return todoLists.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoLists[section].todos.count + 1 // For AddTodo..
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let list = todoLists[indexPath.section]
        if list.todos.count == indexPath.row {
            let cell: AddTodoCell = tableView.dequeueReusableCell(for: indexPath)
            cell.delegate = self
            return cell
        }
        let cell: TodoCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(data: list.todos[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // TODO: custom
        return todoLists[section].name
    }

    // TODO: Enable deleting!
}

// MARK: - AddTodoCellDelegate

extension TodoViewController: AddTodoCellDelegate {
    func addTodoCell(_ cell: AddTodoCell, isEditing textView: UITextView) {
        UIView.setAnimationsEnabled(false)
        textView.sizeToFit()
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }

    func addTodoCell(_ cell: AddTodoCell, didEndEditing todo: String) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            assertionFailure()
            return
        }

        // TODO: update model and add item! to that list
        print(todo)
    }
}
