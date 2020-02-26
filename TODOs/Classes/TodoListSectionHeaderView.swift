//
//  TodoListSectionHeaderView.swift
//  TODOs
//
//  Created by Kevin Johnson on 2/16/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import UIKit

protocol TodoListSectionHeaderViewDelegate: class {
    func todoListSectionHeaderView(_ view: TodoListSectionHeaderView, tappedAction section: Int)
}

class TodoListSectionHeaderView: UIView {

    weak var delegate: TodoListSectionHeaderViewDelegate?
    var section: Int!

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold).scaledFontforTextStyle(.body)
        return label
    }()

    // TODO: how to scale this for dynamic type? look up // make a bit larger now
    private let actionButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(scale: .medium)
        let trashImage = UIImage(
            systemName: "square.and.arrow.up",
            withConfiguration: imageConfig
        )
        let button = UIButton()
        button.setImage(trashImage, for: .normal)
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
        actionButton.isHidden = !data.showTrash
    }
    
    private func setup() {
        backgroundColor = .tertiarySystemBackground // not right on light mode

        actionButton.addTarget(self, action: #selector(tappedTrash(_:)), for: .touchUpInside)

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
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.0)
        ])
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

    @IBAction func tappedTrash(_ sender: UIButton) {
        delegate?.todoListSectionHeaderView(self, tappedAction: self.section)
    }
}
