//
//  UIAlertController+Extensions.swift
//  TODOs
//
//  Created by Kevin Johnson on 2/15/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import UIKit

extension UIAlertController {
    static func addTodoAlert(
        presenter: UIViewController,
        completion: @escaping (_ name: String) -> Void
    ) {
        let alertController = UIAlertController(
            title: "Create new todo list",
            message: nil,
            preferredStyle: .alert
        )

        let textField = UITextField()
        textField.placeholder = "Name of list.."
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .clear
        textField.translatesAutoresizingMaskIntoConstraints = false
        alertController.view.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 64.0),
            textField.bottomAnchor.constraint(equalTo: alertController.view.bottomAnchor, constant: -64.0),
            textField.centerXAnchor.constraint(equalTo: alertController.view.centerXAnchor),
            textField.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 8.0),
            textField.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -8.0)
        ])

        alertController.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel
            )
        )
        alertController.addAction(
            UIAlertAction(
                title: "Create",
                style: .default,
                handler: { _ in
                    guard let text = textField.text, !text.isEmpty else {
                        return
                    }
                    completion(text)
                }
            )
        )
        presenter.present(alertController, animated: true, completion: {
            textField.becomeFirstResponder()
        })
    }

    static func deleteTodoList(
        presenter: UIViewController,
        completion: @escaping (_ delete: Bool) -> Void
    ) {
        let alertController = UIAlertController(
            title: "Are you sure you want to delete this list? 🚮",
            message: "Support hasn't been added yet to undo 😝",
            preferredStyle: .alert
        )
        alertController.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: { _ in
                    completion(false)
                }
            )
        )
        alertController.addAction(
            UIAlertAction(
                title: "Delete",
                style: .destructive,
                handler: { _ in
                    completion(true)
                }
            )
        )
        presenter.present(alertController, animated: true)
    }
}
