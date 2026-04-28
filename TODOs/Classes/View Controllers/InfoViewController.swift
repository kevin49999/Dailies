//
//  InfoViewController.swift
//  TODOs
//
//  Created by Kevin Johnson on 6/5/25.
//  Copyright © 2025 Kevin Johnson. All rights reserved.
//

import UIKit

class InfoViewController: UITableViewController {
    @IBOutlet weak private var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 92
        tableView.rowHeight = UITableView.automaticDimension
        versionLabel.text = Bundle.main.versionNumberString
    }
}
