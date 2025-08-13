//
//  ChartLegendView.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 13/08/25.
//

import UIKit

public struct LegendItem {
    public let color: UIColor
    public let text: String
    public init(color: UIColor, text: String) {
        self.color = color; self.text = text
    }
}

public final class ChartLegendView: UIView {
    public var items: [LegendItem] = [] { didSet { rebuild() } }
    private let stack = UIStackView()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 16)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    private func rebuild() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for it in items {
            let dot = UIView()
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.backgroundColor = it.color
            dot.layer.cornerRadius = 4
            dot.widthAnchor.constraint(equalToConstant: 8).isActive = true
            dot.heightAnchor.constraint(equalToConstant: 8).isActive = true

            let lbl = UILabel()
            lbl.text = it.text
            lbl.font = .systemFont(ofSize: 11, weight: .semibold)
            lbl.textColor = .secondaryLabel

            let row = UIStackView(arrangedSubviews: [dot, lbl])
            row.axis = .horizontal
            row.alignment = .center
            row.spacing = 6
            stack.addArrangedSubview(row)
        }
        isHidden = items.isEmpty
    }
}
