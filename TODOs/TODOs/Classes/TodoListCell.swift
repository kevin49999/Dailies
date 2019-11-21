//
//  TodoListCell.swift
//  TODOs
//
//  Created by Kevin Johnson on 11/20/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit

class TodoListCell: UITableViewCell {

    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var tableViewHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tableView.dataSource = nil // ..
    }
    
    private func setup() {
        tableView.register(cell: TodoCell.self)
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        
        // set height
        tableView.reloadData()
        tableView.layoutIfNeeded()
        print(self.tableView.contentSize.height)
        self.tableViewHeight.constant = self.tableView.contentSize.height
    }
}

extension TodoListCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TodoCell = tableView.dequeueReusableCell(for: indexPath)
        // config..
        return cell
    }
}
