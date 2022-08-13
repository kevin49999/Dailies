//
//  UIAlertController+Extensions.swift
//  TODOs
//
//  Created by Kevin Johnson on 2/15/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import UIKit

// MARK: - UIAlertAction

extension UIAlertAction {
    static func cancel(_ handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction{
        return UIAlertAction(title: "Cancel", style: .cancel, handler: handler)
    }

    static func delete(_ handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction{
        return UIAlertAction(title: "Delete", style: .destructive, handler: handler)
    }

    static func ok(_ handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction{
        return UIAlertAction(title: "OK", style: .default, handler: handler)
    }
}

// MARK: - Utility

extension UIAlertController {
    func addActions(_ alerts: [UIAlertAction]) {
        for alert in alerts {
            addAction(alert)
        }
    }
}

// MARK: - Custom Configurations

extension UIAlertController {
    static func addTodoListAlert(
        presenter: UIViewController,
        textFieldDelegate: UITextFieldDelegate?,
        completion: @escaping (_ name: String) -> Void
    ) -> UIAlertController {
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
        textField.returnKeyType = .done
        textField.delegate = textFieldDelegate
        alertController.view.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 64.0),
            textField.bottomAnchor.constraint(equalTo: alertController.view.bottomAnchor, constant: -64.0),
            textField.centerXAnchor.constraint(equalTo: alertController.view.centerXAnchor),
            textField.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 8.0),
            textField.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -8.0)
        ])

        alertController.addActions([
            UIAlertAction(
                title: "Create",
                style: .default,
                handler: { _ in
                    guard let text = textField.text, !text.isEmpty else {
                        return
                    }
                    completion(text)
                }
            ),
            UIAlertAction.cancel()
        ])

        presenter.present(alertController, animated: true, completion: {
            textField.becomeFirstResponder()
        })
        return alertController
    }

    static func editTodoListAlert(
        _ name: String,
        presenter: UIViewController,
        completion: @escaping (_ name: String) -> Void
    ) {
        let alertController = UIAlertController(
            title: "Edit todo list name",
            message: nil,
            preferredStyle: .alert
        )

        let textField = UITextField()
        textField.text = name
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

        alertController.addActions([
            UIAlertAction(
                title: "Update",
                style: .default,
                handler: { _ in
                    guard let text = textField.text, !text.isEmpty else {
                        return
                    }
                    completion(text)
                }
            ),
            UIAlertAction.cancel()
        ])

        presenter.present(alertController, animated: true, completion: {
            textField.becomeFirstResponder()
        })
    }

    static func deleteTodoList(
        _ listName: String,
        presenter: UIViewController,
        completion: @escaping (_ delete: Bool) -> Void
    ) {
        let alertController = UIAlertController(
            title: "Are you sure you want to delete \"\(listName)?\" 🚮",
            message: "Support hasn't been added yet to undo 😝",
            preferredStyle: .alert
        )

        alertController.addActions([
            UIAlertAction.delete { _ in
                completion(true)
            },
            UIAlertAction.cancel()
        ])

        presenter.present(alertController, animated: true)
    }

    static func todoListActions(
        _ showCompleted: Bool,
        presenter: UIViewController,
        completion: @escaping (_ toggle: Bool) -> Void
    ) {
        let alertController = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )

        alertController.addActions([
            UIAlertAction(
                title: showCompleted ? "Hide Completed" : "Show Completed",
                style: .default,
                handler: { _ in
                    completion(true)
                }
            ),
            UIAlertAction.cancel()
        ])

        presenter.present(alertController, animated: true)
    }
}
