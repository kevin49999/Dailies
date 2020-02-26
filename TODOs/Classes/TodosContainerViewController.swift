//
//  TodosContainerViewController.swift
//  TODOs
//
//  Created by Kevin Johnson on 11/19/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit

// Top 4 4️⃣
// Before publish: App Icon, README, License
// Reorder sections TodoLists 🤔 drag and drop how to (once established there use elsewhere)? If can't get it, come up with dumb solution
// Sizeup + make action item accessible/scale w/ accessibility category
// If day changed while backgrounded, when didComeBack, update current day if it changed (AppDelegate notification?)

// Notes on phone..

// 💡 UITableViewDiffableDataSource w/ dynamic section names and cases basically, how to do..

class TodosContainerViewController: UIViewController {

    // MARK: - Properties

    private let defaults: UserDefaults = .standard
    private var state: TodoList.Classification = .created {
        didSet {
            switch state {
            case .created:
                daysOfWeekTodoController.remove()
                add(createdTodoViewController)
                navigationItem.rightBarButtonItems?[0].isEnabled = true
            case .daysOfWeek:
                createdTodoViewController.remove()
                add(daysOfWeekTodoController)
                navigationItem.rightBarButtonItems?[0].isEnabled = false
            }
        }
    }
    private var isEditingLists: Bool = false

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
        UIAlertController.addTodoListAlert(presenter: self, completion: { name in
            self.createdTodoViewController.addNewTodoList(with: name)
        })
    }

    @IBAction func tappedEditDoneBarButtonItem(_ sender: UIBarButtonItem) {
        // TODO: Do custom grab to reorder like Trello/SwiftReorder
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

    // MARK: - Notification

    @objc func willResignActive() {
        try? TodoList.saveCreated(createdTodoViewController.todoLists)
        try? TodoList.saveDaysOfWeek(daysOfWeekTodoController.todoLists)
    }
}
