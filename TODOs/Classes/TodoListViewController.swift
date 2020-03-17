//
//  TodoListViewController.swift
//  TODOs
//
//  Created by Kevin Johnson on 2/23/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import UIKit

class TodoListViewController: UIViewController {

    // MARK: - Properties

    private(set) var todoLists: [TodoList]
    private let tableView: UITableView = UITableView()

    // MARK: - Init

    init(todoLists: [TodoList]) {
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
        tableView.register(cell: TodoCell.self)
        tableView.register(cell: AddTodoCell.self)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 92
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 44
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.clipsToBounds = true

        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 0
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: 0
            ),
            tableView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: 0
            ),
            tableView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 0
            )
        ])
    }

    // MARK: - Public Functions

    func updateTodoLists(_ lists: [TodoList]) {
        todoLists = lists
        tableView.reloadData()
    }

    func setEditing(_ editing: Bool) {
        tableView.isEditing = editing
    }
    
    func addNewTodoList(with name: String) {
        todoLists.insert(
            TodoList(classification: .created, name: name),
            at: 0
        )
        tableView.insertSections(IndexSet(arrayLiteral: 0), with: .automatic)
    }
}

// MARK: - UITableViewDataSource

extension TodoListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return todoLists.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoLists[section].todos.count + 1 // for AddTodoCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let list = todoLists[indexPath.section]
        if list.todos.count == indexPath.row {
            let cell: AddTodoCell = tableView.dequeueReusableCell(for: indexPath)
            if indexPath.section == todoLists.count - 1 {
                cell.separatorInset = .hideSeparator // hide last
            }
            cell.delegate = self
            return cell
        }
        let cell: TodoCell = tableView.dequeueReusableCell(for: indexPath)
        cell.delegate = self
        cell.configure(data: list.todos[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if todoLists[indexPath.section].todos.count == indexPath.row {
            return false // AddTodoCell
        }
        return true
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if todoLists[indexPath.section].todos.count == indexPath.row {
            return false // AddTodoCell
        }
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceTodoList = todoLists[sourceIndexPath.section]
        let destinationTodoList = todoLists[destinationIndexPath.section]
        let movedTodo = sourceTodoList.todos.remove(at: sourceIndexPath.row)
        destinationTodoList.todos.insert(movedTodo, at: destinationIndexPath.row)
    }
}

// MARK: - UITableViewDelegate

extension TodoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteItem = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            _ = self.todoLists[indexPath.section].todos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        let markCompleted = UIContextualAction(style: .normal, title: "Completed") {  (contextualAction, view, boolValue) in
            // TODO: Don't just delete, update TodoList to have completed array that have their own display cell (not editable, but delatable)
            _ = self.todoLists[indexPath.section].todos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        markCompleted.backgroundColor = .systemGreen
        return UISwipeActionsConfiguration(actions: [deleteItem, markCompleted])
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = TodoListSectionHeaderView()
        header.configure(data: todoLists[section])
        header.delegate = self
        header.section = section
        return header
    }
}

// MARK: - AddTodoCellDelegate

extension TodoListViewController: AddTodoCellDelegate {
    func addTodoCell(_ cell: AddTodoCell, isEditing textView: UITextView) {
        UIView.setAnimationsEnabled(false)
        textView.sizeToFit()
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }

    func addTodoCell(_ cell: AddTodoCell, didEndEditing text: String) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            assertionFailure()
            return
        }
        todoLists[indexPath.section].todos.append(Todo(text: text))
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
}

// MARK: TodoCellDelegate

extension TodoListViewController: TodoCellCellDelegate {
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

// MARK: - TodoListSectionHeaderViewDelegate

extension TodoListViewController: TodoListSectionHeaderViewDelegate {
    func todoListSectionHeaderView(_ view: TodoListSectionHeaderView, tappedAction section: Int) {
        let selectionsAlert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )

        selectionsAlert.addActions([
            UIAlertAction(title: "Rename", style: .default, handler: { _ in
                UIAlertController.editTodoListAlert(
                    self.todoLists[section].name,
                    presenter: self
                ) { name in
                    self.todoLists[section].name = name
                    self.tableView.reloadSections(IndexSet(arrayLiteral: section), with: .automatic)
                }
            }),
            UIAlertAction(title: "Edit Lists", style: .default, handler: { _ in
                let controller: TodoListsViewController = .init(
                    delegate: self,
                    todoLists: self.todoLists
                )
                self.present(controller, animated: true)
            }),
            UIAlertAction.cancel()
        ])
        present(selectionsAlert, animated: true)
    }
}

// MARK: - TodoListsViewControllerDelegate

extension TodoListViewController: TodoListsViewControllerDelegate {
    func todoListsViewController(_ controller: TodoListsViewController, orderedLists: [TodoList]) {
        self.todoLists = orderedLists
        tableView.reloadData()
    }
}
