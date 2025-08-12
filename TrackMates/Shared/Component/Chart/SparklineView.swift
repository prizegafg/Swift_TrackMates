//
//  SparklineView.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 13/08/25.
//

import UIKit

public final class SparklineView: UIView {
    public var values: [Double] = [] { didSet { setNeedsLayout() } }
    public var lineWidth: CGFloat = 2
    public var fill: Bool = true

    private let lineLayer = CAShapeLayer()
    private let fillLayer = CAShapeLayer()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        [fillLayer, lineLayer].forEach { layer.addSublayer($0) }
        lineLayer.strokeColor = UIColor.tmTint.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.lineWidth = lineWidth
        fillLayer.fillColor = UIColor.tmTint.withAlphaComponent(0.12).cgColor
    }
    required init?(coder: NSCoder) { fatalError() }

    public override func layoutSubviews() {
        super.layoutSubviews()
        guard values.count > 1 else { lineLayer.path = nil; fillLayer.path = nil; return }
        let maxV = max(values.max() ?? 1, 1)
        let minV = min(values.min() ?? 0, maxV)
        let range = max(maxV - minV, 0.0001)
        let w = bounds.width, h = bounds.height
        let stepX = w / CGFloat(values.count - 1)

        let path = UIBezierPath()
        for (i, v) in values.enumerated() {
            let x = CGFloat(i) * stepX
            let y = h - CGFloat((v - minV) / range) * h
            (i == 0) ? path.move(to: .init(x: x, y: y)) : path.addLine(to: .init(x: x, y: y))
        }
        lineLayer.path = path.cgPath

        if fill {
            let fillP = UIBezierPath(cgPath: path.cgPath)
            fillP.addLine(to: CGPoint(x: w, y: h))
            fillP.addLine(to: CGPoint(x: 0, y: h))
            fillP.close()
            fillLayer.path = fillP.cgPath
        } else {
            fillLayer.path = nil
        }
    }
}
