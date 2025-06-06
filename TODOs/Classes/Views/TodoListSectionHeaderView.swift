//
//  TodoListSectionHeaderView.swift
//  TODOs
//
//  Created by Kevin Johnson on 2/16/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import UIKit

protocol TodoListSectionHeaderViewDelegate: AnyObject {
    func todoListSectionHeaderView(_ view: TodoListSectionHeaderView, toggledShowComplete section: Int)
}

class TodoListSectionHeaderView: UIView {
    weak var delegate: TodoListSectionHeaderViewDelegate?
    var section: Int = 0
    
    private var showCompleted: Bool = false

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold).scaledFontforTextStyle(.body)
        return label
    }()

    private let toggleCompleteButton: UIButton = {
        let b = UIButton()
        b.contentMode = .scaleAspectFit
        return b
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

    func configure(data: TodoList) {
        titleLabel.text = data.nameDayMonth
        showCompleted = data.showCompleted
        let toggleIcon = UIImage(
            systemName: showCompleted ? "text.book.closed.fill" : "text.book.closed",
            withConfiguration: UIImage.SymbolConfiguration(scale: .medium)
        )
        toggleCompleteButton.setImage(toggleIcon, for: .normal)
    }

    private func setup() {
        backgroundColor = .systemGroupedBackground
        toggleCompleteButton.addTarget(self, action: #selector(tappedAction(_:)), for: .touchUpInside)

        if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
            stackView.axis = .vertical
            stackView.alignment = .leading
        } else {
            stackView.axis = .horizontal
            stackView.alignment = .fill
        }
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(toggleCompleteButton)
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12.0),
            toggleCompleteButton.heightAnchor.constraint(equalToConstant: 34),
            toggleCompleteButton.widthAnchor.constraint(equalToConstant: 34)
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
        delegate?.todoListSectionHeaderView(self, toggledShowComplete: self.section)
    }
}
