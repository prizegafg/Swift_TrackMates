//
//  DSCard.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 13/08/25.
//

import UIKit

public final class DSCard: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .tmCardBackground
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 12
        layer.shadowOffset = .init(width: 0, height: 6)
        translatesAutoresizingMaskIntoConstraints = false
    }
    required init?(coder: NSCoder) { fatalError() }
}
