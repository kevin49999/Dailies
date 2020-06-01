//
//  UndoItem.swift
//  TODOs
//
//  Created by Kevin Johnson on 6/1/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import UIKit

class UndoItem {

    private var completion: ((Bool) -> Void)
    private var view: UndoView!

    init(
        presenterView: UIView,
        completion: @escaping ((Bool) -> Void)
    ) {
        self.completion = completion
        self.view = UndoView(
            config: .init(title: "Undo Mark Completed", backgroundColor: .systemIndigo),
            delegate: self
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        presenterView.addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: presenterView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            view.trailingAnchor.constraint(equalTo: presenterView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            view.bottomAnchor.constraint(equalTo: presenterView.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        view.alpha = 0.0
        UIView.animate(withDuration: 0.5, animations: {
            self.view.alpha = 1.0
        }, completion: { _ in
            _ = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { [weak self] _ in
                self?.dismiss(undo: false)
            })
        })
    }

    func dismiss(undo: Bool) {
        UIView.animate(withDuration: 0.5, animations: {
            self.view.alpha = 0.0
        }, completion: { _ in
            self.view.removeFromSuperview()
            self.completion(undo)
        })
    }
}

extension UndoItem: UndoViewDelegate {
    func undoViewDidTapUndo(_ view: UndoView) {
        dismiss(undo: true)
    }

    func undoViewDidTapCancel(_ view: UndoView) {
        dismiss(undo: false)
    }
}
