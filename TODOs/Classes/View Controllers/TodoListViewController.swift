//
//  TodoListViewController.swift
//  TODOs
//
//  Created by Kevin Johnson on 2/23/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import StoreKit
import UIKit

class TodoListViewController: UIViewController {

    // MARK: - Properties

    private(set) var dataSource: TodoListTableViewDataSource!
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.dragInteractionEnabled = true
        table.register(cell: TodoCell.self)
        table.register(cell: AddTodoCell.self)
        table.register(
            TodoListSectionHeaderView.self,
            forHeaderFooterViewReuseIdentifier: "sectionHeader"
        )
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 65
        table.sectionHeaderHeight = UITableView.automaticDimension
        table.estimatedSectionHeaderHeight = 44
        table.tableFooterView = UIView(frame: .zero)
        table.clipsToBounds = true
        table.translatesAutoresizingMaskIntoConstraints = false
        table.showsVerticalScrollIndicator = false
        return table
    }()

    // MARK: - Init

    init(todoLists: [TodoList]) {
        super.init(nibName: nil, bundle: nil)
        self.dataSource = .init(tableView: tableView, todoLists: todoLists, cellDelegate: self)
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
        tableView.delegate = self
        tableView.dataSource = dataSource
        tableView.dropDelegate = self
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        //
        tableView.keyboardDismissMode = .interactiveWithAccessory
        NSLayoutConstraint.activate([
            tableView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        ])
        tableView.contentInset.bottom = keyboardHeight // this is handled automatically by the guide
        
        dataSource.applySnapshot(animatingDifferences: false)
    }

    // MARK: - Public Functions

    func updateTodoLists(_ lists: [TodoList]) {
        dataSource.todoLists = lists
        dataSource.applySnapshot()
    }
}

// MARK: - UITableViewDelegate

extension TodoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let list =  dataSource.todoLists[indexPath.section]
        let todo = list.visible[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completion) in
            list.remove(at: indexPath.row)
            self.dataSource.delete(todo)
            Undo.shared.show(title: "Undo Delete \"\(todo.text)\"", completion: { undo in
                if undo {
                    list.insert(todo: Todo(text: todo.text), index: indexPath.row)
                    self.dataSource.applySnapshot()
                }
            })
            completion(true)
        }
        let duplicate = UIContextualAction(
            style: .normal,
            title: "Duplicate"
        ) {  (_, _, completion) in
            let duplicate = list.duplicate(at: indexPath.row)
            self.dataSource.insert(duplicate, after: todo)
            completion(true)
        }
        duplicate.backgroundColor = .systemIndigo
        let complete = UIContextualAction(
            style: .normal,
            title: todo.completed ? "Not Complete" : "Complete"
        ) {  (_, _, completion) in
            let result = list.toggleCompleted(index: indexPath.row)
            switch result {
            case .delete:
                self.dataSource.delete(todo)
            case .reload:
                self.dataSource.reload(todo, animate: false)
            }
            completion(true)
        }
        complete.backgroundColor = .systemGreen
        return UISwipeActionsConfiguration(actions: [delete, duplicate, complete])
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "sectionHeader") as! TodoListSectionHeaderView
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

    func addTodoCell(_ cell: AddTodoCell, didEndEditing textView: UITextView) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            assertionFailure()
            return
        }
        
        dataSource.todoLists[indexPath.section].add(todo: Todo(text: textView.text))
        dataSource.applySnapshot()
        cell.reset()
        tableView.resize(for: textView)
        // review action could be anything
        SKStoreReviewController.incrementReviewAction()
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
        } else {
            // kinda nice, delete if text empty, Apple does this in Reminders
            let list = dataSource.todoLists[indexPath.section]
            let todo = list.remove(at: indexPath.row)
            dataSource.delete(todo)
        }
    }
}

// MARK: - TodoListSectionHeaderViewDelegate

extension TodoListViewController: TodoListSectionHeaderViewDelegate {
    func todoListSectionHeaderView(_ view: TodoListSectionHeaderView, toggledShowComplete section: Int) {
        dataSource.todoLists[section].showCompleted.toggle()
        dataSource.applySnapshot()
        view.configure(data: dataSource.todoLists[section]) // gotta call
    }
}
