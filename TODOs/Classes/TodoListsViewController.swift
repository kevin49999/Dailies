//
//  TodoListsViewController.swift
//  TODOs
//
//  Created by Kevin Johnson on 3/17/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import UIKit

protocol TodoListsViewControllerDelegate: class {
    func todoListsViewController(_ controller: TodoListsViewController, orderedLists: [TodoList])
}

class TodoListsViewController: UIViewController {

    // MARK: - Properties

    weak var delegate: TodoListsViewControllerDelegate?
    private(set) var todoLists: [TodoList]
    private let tableView: UITableView = UITableView()

    // MARK: - Init

    init(
        delegate: TodoListsViewControllerDelegate? = nil,
        todoLists: [TodoList]
    ) {
        self.delegate = delegate
        self.todoLists = todoLists
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 92
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 44
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.clipsToBounds = true
        tableView.register(cell: TodoCell.self)
        tableView.isEditing = true

        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            tableView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),
            tableView.topAnchor.constraint(
                equalTo: view.topAnchor
            )
        ])
    }
}

// MARK: - UITableViewDataSource

extension TodoListsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoLists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TodoCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(data: todoLists[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedTodo = todoLists.remove(at: sourceIndexPath.row)
        todoLists.insert(movedTodo, at: destinationIndexPath.row)
        delegate?.todoListsViewController(self, orderedLists: todoLists)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        UIAlertController.deleteTodoList(
            self.todoLists[indexPath.row].name,
            presenter: self
        ) { delete in
            guard delete else { return }
            self.todoLists.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.delegate?.todoListsViewController(self, orderedLists: self.todoLists)
        }
    }
}

// MARK: - UITableViewDelegate

extension TodoListsViewController: UITableViewDelegate { }

// MARK: TodoCellDelegate

extension TodoListsViewController: TodoCellCellDelegate {
    func todoCell(_ cell: TodoCell, isEditing textView: UITextView) {
        // dry/still looks slightly wrong here some jank (took a screenshot of message)
        UIView.setAnimationsEnabled(false)
        textView.sizeToFit()
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }

    func todoCell(_ cell: TodoCell, didEndEditing text: String) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            assertionFailure()
            return
        }
        if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            todoLists[indexPath.section].todos[indexPath.row].text = text
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
