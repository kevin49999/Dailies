//
//  TodoListSectionHeaderView.swift
//  TODOs
//
//  Created by Kevin Johnson on 2/16/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import UIKit

protocol TodoListSectionHeaderViewDelegate: AnyObject {
    func todoListSectionHeaderView(_ view: TodoListSectionHeaderView, tappedAction section: Int)
}

class TodoListSectionHeaderView: UIView {

    weak var delegate: TodoListSectionHeaderViewDelegate?
    var section: Int = 0

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold).scaledFontforTextStyle(.body)
        return label
    }()

    private let actionButton: UIButton = {
        let ellipsis = UIImage(
            systemName: "ellipsis",
            withConfiguration: UIImage.SymbolConfiguration(scale: .medium)
        )
        let button = UIButton()
        button.contentMode = .scaleAspectFit
        button.setImage(ellipsis, for: .normal)
        return button
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = UIStackView.spacingUseSystem
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(data: TodoListViewData) {
        titleLabel.text = data.titleCopy()
    }

    private func setup() {
        backgroundColor = .systemGroupedBackground
        actionButton.addTarget(self, action: #selector(tappedAction(_:)), for: .touchUpInside)

        if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
            stackView.axis = .vertical
            stackView.alignment = .leading
        } else {
            stackView.axis = .horizontal
            stackView.alignment = .fill
        }
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(actionButton)
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12.0),
            actionButton.heightAnchor.constraint(equalToConstant: 34),
            actionButton.widthAnchor.constraint(equalToConstant: 34)
        ])
        let bottom = stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.0)
        bottom.priority = UILayoutPriority(rawValue: 999)
        bottom.isActive = true
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory else {
            return
        }
        if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
            stackView.axis = .vertical
            stackView.alignment = .leading
        } else {
            stackView.axis = .horizontal
            stackView.alignment = .fill
        }
    }

    @IBAction func tappedAction(_ sender: UIButton) {
        delegate?.todoListSectionHeaderView(self, tappedAction: self.section)
    }
}
