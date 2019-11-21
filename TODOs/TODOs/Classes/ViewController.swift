//
//  ViewController.swift
//  TODOs
//
//  Created by Kevin Johnson on 11/19/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak private var tableView: UITableView! // test.. going to need to map TODOs to dates and general categories that have been added
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(cell: TodoListCell.self)
        tableView.estimatedRowHeight = 250
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.reloadData()
        tableView.layoutIfNeeded()
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TodoListCell = tableView.dequeueReusableCell(for: indexPath)
        // config
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
}
// ++ TBV delegate, no scrolling but allow reording, swipe to mark complete ++ cell at bottom to add item

