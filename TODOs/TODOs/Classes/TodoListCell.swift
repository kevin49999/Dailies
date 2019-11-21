//
//  TodoListCell.swift
//  TODOs
//
//  Created by Kevin Johnson on 11/20/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit

class TodoListCell: UITableViewCell {

    private var heightBuffer: [CGFloat] = []
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
        tableView.dataSource = self // ..
        //tableView.delegate = self
        tableView.tableFooterView = UIView(frame: .zero)
        
        //tableView.reloadData()
        //tableView.layoutIfNeeded()
        let height: CGFloat = tableView.visibleCells.map { $0.frame.height }.reduce(0, +)
        print(height, "😡")
        self.tableViewHeight.constant = height // bottom separator clip
    }
}

// MARK: - UITableViewDataSource

extension TodoListCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TodoCell = tableView.dequeueReusableCell(for: indexPath)
        // ..
        return cell
    }
}

// MARK: - UITableViewDelegate

//extension TodoListCell: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        return UIView()
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 1 // hide last cell separator
//    }
//}
