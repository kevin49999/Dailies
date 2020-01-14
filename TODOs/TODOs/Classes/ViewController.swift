//
//  ViewController.swift
//  TODOs
//
//  Created by Kevin Johnson on 11/19/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit

// add keyboard mgmt, UITableViewDiffableDataSource

class ViewController: UIViewController {

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
    var tables: [TodoTableView] = []

    @IBOutlet weak var todoListsStackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()

        for (i, _) in todoLists.enumerated() {
            let table = TodoTableView()
            table.tag = i
            table.dataSource = self
            todoListsStackView.addArrangedSubview(table)
            NSLayoutConstraint.activate([
                table.heightAnchor.constraint(equalToConstant: 275) // TODO: big todo, self sizing of the tableView..
            ])
            tables.append(table)
        }
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoLists[tableView.tag].todos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TodoCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(data: todoLists[tableView.tag].todos[indexPath.row])
        return cell
    }
}

///
class TodoTableView: UITableView {

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        register(cell: TodoCell.self)
        estimatedRowHeight = 250
        rowHeight = UITableView.automaticDimension
        isScrollEnabled = false
    }
}

//
struct TodoList {
    let name: String
    let todos: [Todo]
}

struct Todo {
    let text: String
}

extension Todo: TodoViewData { }

protocol TodoViewData {
    var text: String { get }
}
