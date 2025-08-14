//
//  StatRow.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 14/08/25.
//

import UIKit

public final class StatRow: UIControl {
    private let iconWrap = UIView()
    private let iconView = UIImageView()
    private let titleLbl = UILabel()
    private let valueLbl = UILabel()

    public convenience init(title: String, value: String, icon: String) {
        self.init(frame: .zero)
        set(title: title, value: value, icon: icon)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .staticText
        build()
        layoutUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Configure
    public func set(title: String, value: String, icon: String) {
        titleLbl.text = title
        valueLbl.text = value
        iconView.image = UIImage(systemName: icon)
        accessibilityLabel = "\(title), \(value)"
    }

    // MARK: - UI
    private func build() {
        iconWrap.translatesAutoresizingMaskIntoConstraints = false
        iconWrap.backgroundColor = .tmFieldBackground
        iconWrap.layer.cornerRadius = 18

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = .tmTint
        iconView.contentMode = .scaleAspectFit

        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.font = .systemFont(ofSize: 14, weight: .medium)
        titleLbl.textColor = .tmLabelPrimary

        valueLbl.translatesAutoresizingMaskIntoConstraints = false
        valueLbl.font = .systemFont(ofSize: 16, weight: .semibold)
        valueLbl.textColor = .tmLabelPrimary
        valueLbl.setContentCompressionResistancePriority(.required, for: .horizontal)

        addSubview(iconWrap)
        iconWrap.addSubview(iconView)
        addSubview(titleLbl)
        addSubview(valueLbl)
    }

    private func layoutUI() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 56),

            iconWrap.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            iconWrap.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconWrap.widthAnchor.constraint(equalToConstant: 36),
            iconWrap.heightAnchor.constraint(equalToConstant: 36),

            iconView.centerXAnchor.constraint(equalTo: iconWrap.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconWrap.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor),

            titleLbl.leadingAnchor.constraint(equalTo: iconWrap.trailingAnchor, constant: 10),
            titleLbl.centerYAnchor.constraint(equalTo: centerYAnchor),

            valueLbl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            valueLbl.centerYAnchor.constraint(equalTo: centerYAnchor),

            titleLbl.trailingAnchor.constraint(lessThanOrEqualTo: valueLbl.leadingAnchor, constant: -10)
        ])
    }

    public override var isHighlighted: Bool {
        didSet { iconWrap.alpha = isHighlighted ? 0.8 : 1.0 }
    }
}
