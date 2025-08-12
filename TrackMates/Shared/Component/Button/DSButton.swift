//
//  DSButton.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 12/08/25.
//

import UIKit

public enum ButtonStyle { case primary, link }

public final class PrimaryButton: UIButton {
    public convenience init(_ title: String) {
        self.init(type: .system)
        setTitle(title, for: .normal)
        backgroundColor = .tmAccent
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .boldSystemFont(ofSize: 16)
        layer.cornerRadius = DesignSystem.Metric.radius
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: DesignSystem.Metric.buttonHeight).isActive = true
    }
}

public final class TransparantButton: UIButton {
    public convenience init(_ title: String) {
        self.init(type: .system)
        setTitle(title, for: .normal)
        setTitleColor(.tmAccent, for: .normal) 
        titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        contentEdgeInsets = DesignSystem.Metric.inset
        translatesAutoresizingMaskIntoConstraints = false
    }
}

enum DesignButton {
    static func button(_ title: String, style: ButtonStyle = .primary) -> UIButton {
        switch style {
        case .primary: return PrimaryButton(title)
        case .link:    return TransparantButton(title)
        }
    }
    static func primary(_ title: String) -> UIButton { PrimaryButton(title) }
    static func link(_ title: String) -> UIButton { TransparantButton(title) }
}

// Back-compat optional
extension DesignButton {
    static func makeButton(title: String) -> UIButton { primary(title) }
    static func makeLinkButton(_ title: String) -> UIButton { link(title) }
}
