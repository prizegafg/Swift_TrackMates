//
//  RankListView.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 13/08/25.
//

import UIKit

public struct RankItemVM {
    public let rank: Int
    public let name: String
    public let distanceText: String
    public init(rank: Int, name: String, distanceText: String) {
        self.rank = rank; self.name = name; self.distanceText = distanceText
    }
}

final class RankRowView: UIView {
    private let rankLbl = UILabel()
    private let nameLbl = UILabel()
    private let valueLbl = UILabel()
    private let sep = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        rankLbl.font = .systemFont(ofSize: 13, weight: .semibold)
        rankLbl.textColor = .tmLabelSecondary
        nameLbl.font = .systemFont(ofSize: 15, weight: .medium)
        nameLbl.textColor = .tmLabelPrimary
        valueLbl.font = .systemFont(ofSize: 14, weight: .semibold)
        valueLbl.textColor = .tmLabelSecondary
        sep.backgroundColor = .tmSeparator

        [rankLbl, nameLbl, valueLbl, sep].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        addSubview(rankLbl); addSubview(nameLbl); addSubview(valueLbl); addSubview(sep)

        NSLayoutConstraint.activate([
            rankLbl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            rankLbl.centerYAnchor.constraint(equalTo: centerYAnchor),
            nameLbl.leadingAnchor.constraint(equalTo: rankLbl.trailingAnchor, constant: 12),
            nameLbl.centerYAnchor.constraint(equalTo: centerYAnchor),
            valueLbl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            valueLbl.centerYAnchor.constraint(equalTo: centerYAnchor),
            sep.heightAnchor.constraint(equalToConstant: 1),
            sep.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            sep.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            sep.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    required init?(coder: NSCoder) { fatalError() }
    func apply(_ item: RankItemVM, showSeparator: Bool) {
        rankLbl.text = String(format: "%02d.", item.rank)
        nameLbl.text = item.name
        valueLbl.text = item.distanceText
        sep.isHidden = !showSeparator
    }
}

public final class RankListView: UIView {
    private let stack = UIStackView()
    public var items: [RankItemVM] = [] { didSet { reload() } }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    private func reload() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (i, it) in items.enumerated() {
            let row = RankRowView()
            row.apply(it, showSeparator: i < items.count - 1)
            stack.addArrangedSubview(row)
        }
    }
}
