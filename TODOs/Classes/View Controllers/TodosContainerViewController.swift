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

    typealias State = TodoList.Classification
    private let defaults: UserDefaults = .standard
    private var state: State = .created {
        didSet {
            configure(for: state)
        }
    }

    private lazy var createdTodoViewController: TodoListViewController = {
        TodoListViewController(
            todoLists: TodoList.createdTodoLists(),
            bottomInset: self.toolBar.frame.height,
            emptyString: "No custom lists added.. yet!"
        )
    }()

    private lazy var daysOfWeekTodoController: TodoListViewController = {
        TodoListViewController(
            todoLists: TodoList.daysOfWeekTodoLists(),
            bottomInset: self.toolBar.frame.height,
            emptyString: nil
        )
    }()

    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var listsSegmentedControl: UISegmentedControl!
    @IBOutlet weak private var toolBar: UIToolbar!
    @IBOutlet weak private var settingsBarButtonItem: UIBarButtonItem!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        if let state = defaults.value(forKey: "state") as? Int {
            self.state = State(int: state)
        } else {
            self.state = .daysOfWeek
        }
        observeNotifications()

        let gearImage = UIImage(
            systemName: "gear",
            withConfiguration: UIImage.SymbolConfiguration(scale: .medium)
        )
        settingsBarButtonItem.image = gearImage
        /// inefficient but fine for now, come back and find fast way to apply settings, also causing TableView layout warning 
        settingsChanged()
    }

    // MARK: - Functions

    private func configure(for state: State) {
        switch state {
        case .created:
            daysOfWeekTodoController.remove()
            add(createdTodoViewController, to: contentView)
            navigationItem.rightBarButtonItems?[1].isEnabled = true
            navigationItem.leftBarButtonItem?.isEnabled = true
        case .daysOfWeek:
            createdTodoViewController.remove()
            add(daysOfWeekTodoController, to: contentView)
            navigationItem.rightBarButtonItems?[1].isEnabled = false
            navigationItem.leftBarButtonItem?.isEnabled = false
        }
        listsSegmentedControl.selectedSegmentIndex = (state == .created) ? 1 : 0
    }

    // MARK: - IBAction

    @IBAction func tappedListsBarButtonItem(_ sender: UIBarButtonItem) {
        let controller: TodoListsViewController = .init(
            delegate: self,
            todoLists: createdTodoViewController.dataSource.todoLists
        )

        let nav = UINavigationController(rootViewController: controller)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        nav.navigationBar.standardAppearance = appearance
        nav.navigationBar.scrollEdgeAppearance = nav.navigationBar.standardAppearance
        present(nav, animated: true)
    }

    @IBAction func tappedActionBarButtonItem(_ sender: UIBarButtonItem) {
        assert(state == .created)
        UIAlertController.addTodoListAlert(presenter: self, completion: { name in
            self.createdTodoViewController.addNewTodoList(with: name)
        })
    }

    @IBAction func tappedSettingsBarButtonItem(_ sender: UIBarButtonItem) {
        let settings = UIStoryboard(
            name: "Main",
            bundle: nil
        ).instantiateViewController(identifier: "SettingsViewController") as! SettingsViewController
        navigationController?.pushViewController(settings, animated: true)
    }

    @IBAction func listSegmentedControlChanged(_ sender: UISegmentedControl) {
        /// rawValue of enum no longer matches w/ selectedSegmentIndex
        defaults.set(sender.selectedSegmentIndex == 0 ? 1 : 0, forKey: "state")
        switch sender.selectedSegmentIndex {
        case 0:
            self.state = .daysOfWeek
        case 1:
            self.state = .created

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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(settingsChanged),
            name: .init(rawValue: "SettingsChanged"),
            object: nil
        )
    }

    @objc func willResignActive() {
        try? TodoList.saveCreated(createdTodoViewController.dataSource.todoLists)
        try? TodoList.saveDaysOfWeek(daysOfWeekTodoController.dataSource.todoLists)
    }

    @objc func willEnterForeground() {
        guard let firstDay = daysOfWeekTodoController.dataSource.todoLists.first else {
            fatalError("First day should be set")
        }
        if firstDay.dateCreated.isBefore(Date()) {
            daysOfWeekTodoController.updateTodoLists(TodoList.daysOfWeekTodoLists())
            /// add settings to new days that get it dated
            settingsChanged()
        }
    }

    @objc func settingsChanged() {
        let lists = daysOfWeekTodoController.dataSource.todoLists
        lists.applySettings(Setting.saved())
        daysOfWeekTodoController.updateTodoLists(lists)
    }
}

// MARK: - TodoListsViewControllerDelegate

extension TodosContainerViewController: TodoListsViewControllerDelegate {
    func todoListsViewController(_ controller: TodoListsViewController, finishedEditing lists: [TodoList]) {
        createdTodoViewController.updateTodoLists(lists)
    }
}
