//
//  BarChartView.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 13/08/25.
//

import UIKit

public final class BarChartView: UIView {
    public var values: [Double] = [] { didSet { rebuildBars() } }
    public var barWidth: CGFloat = 10
    public var barSpacing: CGFloat = 10
    public var corner: CGFloat = 4
    public var barColor: UIColor = .tmTint
    public var baselineColor: UIColor = UIColor.tmBorder.withAlphaComponent(0.6)

    private var barLayers: [CAShapeLayer] = []
    private let baseline = CAShapeLayer()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        isAccessibilityElement = false
        layer.addSublayer(baseline)
        baseline.strokeColor = baselineColor.cgColor
        baseline.lineWidth = 1
        baseline.lineCap = .round
        baseline.fillColor = UIColor.clear.cgColor
        backgroundColor = .clear
    }
    required init?(coder: NSCoder) { fatalError() }

    public override func layoutSubviews() {
        super.layoutSubviews()
        layoutBars()
    }

    private func rebuildBars() {
        barLayers.forEach { $0.removeFromSuperlayer() }
        barLayers = values.map { _ in
            let l = CAShapeLayer()
            l.fillColor = barColor.withAlphaComponent(0.95).cgColor
            layer.addSublayer(l)
            return l
        }
        setNeedsLayout()
    }

    private func layoutBars() {
        guard !values.isEmpty else {
            baseline.path = nil; return
        }
        // baseline
        let basePath = UIBezierPath()
        basePath.move(to: CGPoint(x: 0, y: bounds.height - 0.5))
        basePath.addLine(to: CGPoint(x: bounds.width, y: bounds.height - 0.5))
        baseline.path = basePath.cgPath

        // bars
        let maxV = max(values.max() ?? 1, 1)
        let minV = min(values.min() ?? 0, maxV)
        let range = max(maxV - minV, 0.0001)

        let totalW = CGFloat(values.count) * barWidth + CGFloat(values.count - 1) * barSpacing
        let startX = max((bounds.width - totalW) / 2, 0)

        for (idx, v) in values.enumerated() {
            let hRatio = CGFloat((v - minV) / range)
            let h = max(hRatio * bounds.height, 2)
            let x = startX + CGFloat(idx) * (barWidth + barSpacing)
            let y = bounds.height - h

            let rect = CGRect(x: x, y: y, width: barWidth, height: h)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: corner)
            barLayers[idx].path = path.cgPath
        }
    }
}
