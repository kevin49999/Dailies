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

    private lazy var daysOfWeekTodoController: TodoListViewController = {
        TodoListViewController(todoLists: TodoList.daysOfWeekTodoLists())
    }()

    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var settingsBarButtonItem: UIBarButtonItem!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        observeNotifications()
        let gearImage = UIImage(systemName: "gear")?.withConfiguration(UIImage.SymbolConfiguration(scale: .medium))
        settingsBarButtonItem.image = gearImage
        add(daysOfWeekTodoController, to: contentView)
    }

    // MARK: - IBAction

    @IBAction func tappedSettingsBarButtonItem(_ sender: UIBarButtonItem) {
        let settings = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(identifier: "SettingsViewController") as! SettingsViewController
        navigationController?.pushViewController(settings, animated: true)
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
        try? TodoList.saveDaysOfWeek(daysOfWeekTodoController.dataSource.todoLists)
    }

    @objc func willEnterForeground() {
        guard let firstDay = daysOfWeekTodoController.dataSource.todoLists.first else {
            fatalError("First day should be set")
        }
        
        // this != check is also done in TodoList.daysOfWeekTodoLists()
        if firstDay.uniqueDay != DateFormatters.uniqueDay.string(from: Date()) {
            let newList = TodoList.daysOfWeekTodoLists()
            newList.applySettings(Setting.saved())
            daysOfWeekTodoController.updateTodoLists(newList)
        }
    }

    @objc func settingsChanged() {
        let lists = daysOfWeekTodoController.dataSource.todoLists
        lists.applySettings(Setting.saved())
        daysOfWeekTodoController.updateTodoLists(lists)
    }
}
