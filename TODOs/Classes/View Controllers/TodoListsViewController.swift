//
//  TodoListsViewController.swift
//  TODOs
//
//  Created by Kevin Johnson on 3/17/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import UIKit

protocol TodoListsViewControllerDelegate: AnyObject {
    func todoListsViewController(_ controller: TodoListsViewController, finishedEditing lists: [TodoList])
}

class TodoListsViewController: UIViewController {

    // MARK: - Properties

    weak var delegate: TodoListsViewControllerDelegate?
    private(set) var todoLists: [TodoList]
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.dragInteractionEnabled = true
        table.dropDelegate = self
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 65
        table.tableFooterView = UIView(frame: .zero)
        table.clipsToBounds = true
        table.register(cell: TodoCell.self)
        return table
    }()

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
        title = "Edit Lists"
        let save = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(tappedSave(_:))
        )
        navigationItem.rightBarButtonItem = save

        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }

    @IBAction private func tappedSave(_ sender: UIBarButtonItem) {
        delegate?.todoListsViewController(self, finishedEditing: self.todoLists)
        dismiss(animated: true)
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
        cell.delegate = self
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
            let list = self.todoLists.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            Task { try? await CloudDb.shared.deleteList(list) }
        }
    }
}

// MARK: - UITableViewDropDelegate

extension TodoListsViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return .init(operation: .move, intent: .insertAtDestinationIndexPath)
    }

    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) { }
}

// MARK: - UITableViewDelegate

extension TodoListsViewController: UITableViewDelegate { }

// MARK: TodoCellDelegate

extension TodoListsViewController: TodoCellDelegate {
    func todoCell(_ cell: TodoCell, isEditing textView: UITextView) {
        tableView.resize(for: textView)
    }

    func todoCell(_ cell: TodoCell, didEndEditing text: String) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            assertionFailure()
            return
        }
        if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            todoLists[indexPath.row].name = text
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
