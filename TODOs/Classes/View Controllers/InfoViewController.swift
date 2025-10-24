//
//  InfoViewController.swift
//  TODOs
//
//  Created by Kevin Johnson on 6/5/25.
//  Copyright © 2025 Kevin Johnson. All rights reserved.
//

import UIKit

class InfoViewController: UITableViewController {
    static let githubUrl = URL(string: "https://github.com/kevin49999/Dailies")!

    @IBOutlet weak private var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 92
        tableView.rowHeight = UITableView.automaticDimension
        versionLabel.text = Bundle.main.versionNumberString
    }
}

// MARK: - UITableViewDelegate

extension InfoViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: // source code
            tableView.deselectRow(at: indexPath, animated: true)
            UIApplication.shared.open(Self.githubUrl)
        case 1: // build/version
            break
        default:
            assertionFailure()
        }
    }
}

