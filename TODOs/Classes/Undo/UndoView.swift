//
//  UndoView.swift
//  TODOs
//
//  Created by Kevin Johnson on 6/1/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import UIKit

protocol UndoViewDelegate: class {
    func undoViewDidTapUndo(_ view: UndoView)
    func undoViewDidTapCancel(_ view: UndoView)
}

class UndoView: UIView {
    struct Configuration {
        let title: String
        let backgroundColor: UIColor
    }

    // MARK: - Properties

    weak var delegate: UndoViewDelegate?

    private let titleLabel: UILabel = {
        let t = UILabel()
        t.numberOfLines = 0
        t.translatesAutoresizingMaskIntoConstraints = false
        t.textAlignment = .left
        t.adjustsFontForContentSizeCategory = true
        t.font = UIFont.preferredFont(forTextStyle: .subheadline)
        return t
    }()

    private let undoButton: UIButton = {
        let b = UIButton()
        let image = UIImage(
            systemName: "arrow.uturn.left",
            withConfiguration: UIImage.SymbolConfiguration(scale: .medium)
        )
        b.contentMode = .scaleAspectFit
        b.setImage(image, for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(onTapUndo(_:)), for: .touchUpInside)
        return b
    }()

    private let cancelButton: UIButton = {
        let b = UIButton()
        let image = UIImage(
            systemName: "xmark",
            withConfiguration: UIImage.SymbolConfiguration(scale: .medium)
        )
        b.contentMode = .scaleAspectFit
        b.setImage(image, for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(onTapCancel(_:)), for: .touchUpInside)
        return b
    }()

    // MARK: - Init

    init(config: Configuration, delegate: UndoViewDelegate?) {
        self.delegate = delegate
        super.init(frame: .zero)
        backgroundColor = config.backgroundColor

        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        titleLabel.text = config.title
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let buttonStack = UIStackView(arrangedSubviews: [undoButton, cancelButton])
        buttonStack.spacing = UIStackView.spacingUseSystem
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonStack)
        NSLayoutConstraint.activate([
            buttonStack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            buttonStack.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            buttonStack.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: titleLabel.trailingAnchor, multiplier: 1.0)
        ])
        buttonStack.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Actions

    @objc private func onTapUndo(_ sender: UIButton) {
        delegate?.undoViewDidTapUndo(self)
    }

    @objc private func onTapCancel(_ sender: UIButton) {
        delegate?.undoViewDidTapCancel(self)
    }
}
