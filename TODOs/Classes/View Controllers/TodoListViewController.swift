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

    private (set)var dataSource: TodoListTableViewDataSource
    private var bottomInset: CGFloat

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = dataSource
        table.dragInteractionEnabled = true
        table.dragDelegate = self
        table.dropDelegate = self
        table.register(cell: TodoCell.self)
        table.register(cell: AddTodoCell.self)
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 92
        table.sectionHeaderHeight = UITableView.automaticDimension
        table.estimatedSectionHeaderHeight = 44
        table.tableFooterView = UIView(frame: .zero)
        table.clipsToBounds = true
        table.translatesAutoresizingMaskIntoConstraints = false
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.bottomInset, right: 0)
        return table
    }()

    // MARK: - Init

    init(todoLists: [TodoList], bottomInset: CGFloat) {
        self.dataSource = TodoListTableViewDataSource(todoLists: todoLists)
        self.bottomInset = bottomInset
        super.init(nibName: nil, bundle: nil)
        self.dataSource.cellDelegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }

    // MARK: - Public Functions

    func updateTodoLists(_ lists: [TodoList]) {
        dataSource.todoLists = lists
        tableView.reloadData()
    }
    
    func addNewTodoList(with name: String) {
        dataSource.todoLists.insert(.init(classification: .created, name: name), at: 0)
        tableView.insertSections(IndexSet(arrayLiteral: 0), with: .automatic)
    }
}

// MARK: - UITableViewDelegate

extension TodoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let list = dataSource.todoLists[indexPath.section]
        let todo = list.visible[indexPath.row]
        let cp = Todo(text: todo.text, completed: false)

        let delete = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completion) in
            list.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            Undo.shared.show(title: "Undo Delete", completion: { undo in
                if undo {
                    list.reinsert(todo: cp, destination: list, index: indexPath.row)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                }
            })
            completion(true)
        }
        let complete = UIContextualAction(
            style: .normal,
            title: todo.completed ? "Not Complete" : "Completed"
        ) {  (_, _, completion) in
            let result = list.toggleCompleted(index: indexPath.row)
            switch result {
            case .delete:
                tableView.deleteRows(at: [indexPath], with: .automatic)
            case .reload:
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            Undo.shared.show(title: "Undo Toggle Complete") { undo in
                if undo {
                    self.undoToggleCompletedTodo(
                        firstResult: result,
                        list: list,
                        todo: todo,
                        indexPath: indexPath
                    )
                }
            }
            completion(true)
        }
        complete.backgroundColor = .systemGreen
        return UISwipeActionsConfiguration(actions: [delete, complete])
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = TodoListSectionHeaderView()
        header.configure(data: dataSource.todoLists[section])
        header.section = section
        header.delegate = self
        return header
    }

    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        // Disallow moving TodoCell below AddTodoCell
        let proposedSection = proposedDestinationIndexPath.section
        let proposedRow = proposedDestinationIndexPath.row
        let proposedSectionTodosCount = dataSource.todoLists[proposedSection].visible.count

        if sourceIndexPath.section == proposedSection,
            proposedRow == proposedSectionTodosCount {
            return sourceIndexPath
        } else if sourceIndexPath.section != proposedSection,
            proposedRow > proposedSectionTodosCount {
            return IndexPath(row: proposedRow - 1, section: proposedSection)
        }
        return proposedDestinationIndexPath
    }
}

// MARK: - UITableViewDragDelegate

extension TodoListViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return []
    }
}

// MARK: - UITableViewDropDelegate

extension TodoListViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return .init(operation: .move, intent: .insertAtDestinationIndexPath)
    }

    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) { }
}

// MARK: - AddTodoCellDelegate

extension TodoListViewController: AddTodoCellDelegate {
    func addTodoCell(_ cell: AddTodoCell, isEditing textView: UITextView) {
        tableView.resize(for: textView)
    }

    func addTodoCell(_ cell: AddTodoCell, didEndEditing text: String) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            assertionFailure()
            return
        }
        dataSource.todoLists[indexPath.section].add(todo: Todo(text: text))
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
}

// MARK: TodoCellDelegate

extension TodoListViewController: TodoCellDelegate {
    func todoCell(_ cell: TodoCell, isEditing textView: UITextView) {
        tableView.resize(for: textView)
    }

    func todoCell(_ cell: TodoCell, didEndEditing text: String) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            assertionFailure()
            return
        }
        if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let list = dataSource.todoLists[indexPath.section]
            if list.showCompleted {
                list.todos[indexPath.row].text = text
            } else {
                list.incomplete[indexPath.row].text = text
            }
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

// MARK: - TodoListSectionHeaderView

extension TodoListViewController: TodoListSectionHeaderViewDelegate {
    func todoListSectionHeaderView(_ view: TodoListSectionHeaderView, tappedAction section: Int) {
        UIAlertController.todoListActions(
            dataSource.todoLists[section].showCompleted,
            presenter: self,
            completion: { _ in
                self.dataSource.todoLists[section].showCompleted.toggle()
                self.tableView.reloadSections(IndexSet(arrayLiteral: section), with: .automatic)
        })
    }
}

// MARK: - Undo

extension TodoListViewController {
    func undoToggleCompletedTodo(
        firstResult: TodoList.ToggleCompletedResult,
        list: TodoList,
        todo: Todo,
        indexPath: IndexPath
    ) {
        switch firstResult {
        case .delete:
            list.toggleCompleted(index: indexPath.row, onCompleted: true)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
        case .reload:
            let undoResult = list.toggleCompleted(index: indexPath.row)
            switch undoResult {
            case .delete:
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            case .reload:
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
}
