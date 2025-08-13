//
//  MetricItemView.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 13/08/25.
//

import UIKit

public final class MetricItemView: UIView {
    private let titleLbl = UILabel()
    private let valueLbl = UILabel()

    public init(title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        titleLbl.text = title
        titleLbl.font = .systemFont(ofSize: 12, weight: .medium)
        titleLbl.textColor = .tmLabelSecondary
        titleLbl.translatesAutoresizingMaskIntoConstraints = false

        valueLbl.font = .systemFont(ofSize: 16, weight: .semibold)
        valueLbl.textColor = .tmLabelPrimary
        valueLbl.translatesAutoresizingMaskIntoConstraints = false
        valueLbl.setContentCompressionResistancePriority(.required, for: .vertical)

        addSubview(titleLbl)
        addSubview(valueLbl)

        NSLayoutConstraint.activate([
            titleLbl.topAnchor.constraint(equalTo: topAnchor),
            titleLbl.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLbl.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),

            valueLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 4),
            valueLbl.leadingAnchor.constraint(equalTo: leadingAnchor),
            valueLbl.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            valueLbl.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    public func set(_ value: String) {
        valueLbl.text = value
    }
}
