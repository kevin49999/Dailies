//
//  RestoreViewController.swift
//  TODOs
//
//  Created by Kevin Johnson on 9/5/22.
//  Copyright © 2022 Kevin Johnson. All rights reserved.
//

import UIKit

protocol RestoreViewControllerDelegate: AnyObject {
    func restoreViewControllerDidRestore(daysOfWeek: [TodoList], created: [TodoList])
}

class RestoreViewController: UIViewController {
    weak var delegate: RestoreViewControllerDelegate?
    private var daysOfWeek: [TodoList] = []
    private var created: [TodoList] = []

    @IBOutlet weak private var backupLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func configure(
        currentDaysEmpty: Bool,
        daysOfWeek: [TodoList],
        created: [TodoList]
    ) {
        self.daysOfWeek = daysOfWeek
        self.created = created

        var str = ""
        if !currentDaysEmpty {
            str.append("Found daily lists with TODOs")
        }
        if !created.isEmpty {
            if !str.isEmpty {
                str.append(" and found \(created.count) custom lists")
            } else {
                // numberformatter 4 this? or localize?
                if created.count == 1 {
                    str.append("Found \(created.count) custom list")
                } else {
                    str.append("Found \(created.count) custom lists")
                }
            }
        }
        backupLabel.text = str
    }

    @IBAction func didTapRestore(_ sender: UIButton) {
        // it will end up restoring with both, that's okay!
        delegate?.restoreViewControllerDidRestore(daysOfWeek: daysOfWeek, created: created)
        dismiss(animated: true)
    }
}
