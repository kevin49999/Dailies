//
//  TodosContainerViewController.swift
//  TODOs
//
//  Created by Kevin Johnson on 11/19/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

// Rename sections (trash cange to action, w/ 2 options presented in action list)
// Reorder sections TodoLists
// Table round corners and inset entire thing slightly
// UITableViewDiffableDataSource w/ dynamic section names and count basically..

import UIKit

protocol TodosContainerViewControllerDelegate: class {
    func todosContainerViewControllerDidTapEdit(_ controller: TodosContainerViewControllerDelegate)
}

class TodosContainerViewController: UIViewController {

    // MARK: - Properties

    private let defaults: UserDefaults = .standard
    private var state: TodoList.Classification = .created {
        didSet {
            switch state {
            case .created:
                daysOfWeekTodoController.remove()
                add(createdTodoViewController)
                navigationItem.rightBarButtonItems?[1].isEnabled = true
            case .daysOfWeek:
                createdTodoViewController.remove()
                add(daysOfWeekTodoController)
                navigationItem.rightBarButtonItems?[1].isEnabled = false
            }
        }
    }

    private lazy var createdTodoViewController: TodoListViewController = {
        let controller = TodoListViewController(
            todoLists: TodoList.createdTodoLists()
        )
        return controller
    }()
    private lazy var daysOfWeekTodoController: TodoListViewController = {
        let controller = TodoListViewController(
            todoLists: TodoList.daysOfWeekTodoLists()
        )
        return controller
    }()

    @IBOutlet weak private var listsSegmentedControl: UISegmentedControl!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        let state = defaults.integer(forKey: "state")
        listsSegmentedControl.selectedSegmentIndex = state
        self.state = TodoList.Classification(int: state) ?? .created

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    // MARK: - IBAction

    @IBAction func tappedActionBarButtonItem(_ sender: UIBarButtonItem) {
        assert(state == .created)
        UIAlertController.addTodoAlert(presenter: self, completion: { name in
            self.createdTodoViewController.addNewTodoList(with: name)
        })
    }

    @IBAction func tappedEditDoneBarButtonItem(_ sender: UIBarButtonItem) {
        // TODO: Do custom grab to reorder like Trello/SwiftReorder
        //tableView.isEditing.toggle()
//        let barButtonItem = UIBarButtonItem(
//            barButtonSystemItem: tableView.isEditing ? .done : .edit,
//            target:  self,
//            action: #selector(tappedEditDoneBarButtonItem(_:))
//        )
//        barButtonItem.tintColor = .systemPurple
//        navigationItem.rightBarButtonItems![1] = barButtonItem
    }

    @IBAction func listSegmentedControlChanged(_ sender: UISegmentedControl) {
        defaults.set(sender.selectedSegmentIndex, forKey: "state")
        switch sender.selectedSegmentIndex {
        case 0:
            self.state = .created
        case 1:
            self.state = .daysOfWeek
        default:
            fatalError()
        }
    }

    // MARK: - Notification

    @objc func willResignActive() {
        try? TodoList.saveCreated(createdTodoViewController.todoLists)
        try? TodoList.saveDaysOfWeek(daysOfWeekTodoController.todoLists)
    }
}
