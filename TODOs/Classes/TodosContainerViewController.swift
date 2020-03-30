//
//  TodosContainerViewController.swift
//  TODOs
//
//  Created by Kevin Johnson on 11/19/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit

class TodosContainerViewController: UIViewController {

    // MARK: - Properties

    private let defaults: UserDefaults = .standard
    private var state: TodoList.Classification = .created {
        didSet {
            switch state {
            case .created:
                daysOfWeekTodoController.remove()
                add(createdTodoViewController, to: contentView)
                navigationItem.rightBarButtonItems?[0].isEnabled = true
                navigationItem.leftBarButtonItem?.isEnabled = true
            case .daysOfWeek:
                createdTodoViewController.remove()
                add(daysOfWeekTodoController, to: contentView)
                navigationItem.rightBarButtonItems?[0].isEnabled = false
                navigationItem.leftBarButtonItem?.isEnabled = false
            }
        }
    }
    private var isEditingLists: Bool = false

    private lazy var createdTodoViewController: TodoListViewController = {
        TodoListViewController(
            todoLists: TodoList.createdTodoLists(),
            bottomInset: self.toolBar.frame.height
        )
    }()
    private lazy var daysOfWeekTodoController: TodoListViewController = {
        TodoListViewController(
            todoLists: TodoList.daysOfWeekTodoLists(),
            bottomInset: self.toolBar.frame.height
        )
    }()

    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var listsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var toolBar: UIToolbar!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        let state = defaults.integer(forKey: "state")
        listsSegmentedControl.selectedSegmentIndex = state
        self.state = TodoList.Classification(int: state) ?? .created

        observeNotifications()
    }

    // MARK: - IBAction

    @IBAction func tappedListsBarButtonItem(_ sender: UIBarButtonItem) {
        let controller: TodoListsViewController = .init(
            delegate: self,
            todoLists: createdTodoViewController.todoLists
        )
        let nav = UINavigationController(rootViewController: controller)
        present(nav, animated: true)
    }

    @IBAction func tappedActionBarButtonItem(_ sender: UIBarButtonItem) {
        assert(state == .created)
        UIAlertController.addTodoListAlert(presenter: self, completion: { name in
            self.createdTodoViewController.addNewTodoList(with: name)
        })
    }

    @IBAction func tappedEditDoneBarButtonItem(_ sender: UIBarButtonItem) {
        isEditingLists.toggle()
        createdTodoViewController.setEditing(isEditingLists)
        daysOfWeekTodoController.setEditing(isEditingLists)
        let barButtonItem = UIBarButtonItem(
            barButtonSystemItem: self.isEditingLists ? .done : .edit,
            target:  self,
            action: #selector(tappedEditDoneBarButtonItem(_:))
        )
        navigationItem.rightBarButtonItems![1] = barButtonItem
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
}

// MARK: - Notifications

extension TodosContainerViewController {
    private func observeNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    @objc func willResignActive() {
        try? TodoList.saveCreated(createdTodoViewController.todoLists)
        try? TodoList.saveDaysOfWeek(daysOfWeekTodoController.todoLists)
    }

    @objc func willEnterForeground() {
        guard let firstDay = daysOfWeekTodoController.todoLists.first else {
            fatalError("First day should be set")
        }
        if Date.todayYearMonthDay() > firstDay.dateCreated {
            daysOfWeekTodoController.updateTodoLists(TodoList.daysOfWeekTodoLists())
        }
    }
}

// MARK: - TodoListsViewControllerDelegate

extension TodosContainerViewController: TodoListsViewControllerDelegate {
    func todoListsViewController(_ controller: TodoListsViewController, finishedEditing lists: [TodoList]) {
        createdTodoViewController.updateTodoLists(lists)
    }
}
