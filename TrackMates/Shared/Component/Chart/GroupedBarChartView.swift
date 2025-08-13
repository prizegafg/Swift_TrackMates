//
//  GroupedBarChartView.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 13/08/25.
//

import UIKit

public struct ChartSeries {
    public let color: UIColor
    public let values: [Double]
    public init(color: UIColor, values: [Double]) {
        self.color = color
        self.values = values
    }
}

/// Grouped bars with day labels + padding so bars tidak mepet
public final class GroupedBarChartView: UIView {
    // Data
    public var labels: [String] = [] { didSet { rebuildLabels() ; setNeedsLayout() } }
    public var series: [ChartSeries] = [] { didSet { rebuildBars() ; setNeedsLayout() } }

    // Style
    public var barWidth: CGFloat = 8
    public var barSpacing: CGFloat = 4
    public var groupSpacing: CGFloat = 14
    public var corner: CGFloat = 3
    public var contentInset: UIEdgeInsets = .init(top: 6, left: 12, bottom: 22, right: 12) 
    public var labelFont: UIFont = .systemFont(ofSize: 10, weight: .medium)
    public var labelColor: UIColor = .secondaryLabel

    // Layers
    private var barLayers: [[CAShapeLayer]] = []
    private let baseline = CAShapeLayer()

    // Day labels
    private var labelViews: [UILabel] = []

    public override init(frame: CGRect) {
        super.init(frame: frame)
        isAccessibilityElement = false
        backgroundColor = .clear
        layer.addSublayer(baseline)
        baseline.strokeColor = UIColor.tmBorder.withAlphaComponent(0.6).cgColor
        baseline.lineWidth = 1
        baseline.lineCap = .round
        baseline.fillColor = UIColor.clear.cgColor
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Build
    private func rebuildBars() {
        // Remove old layers
        for layers in barLayers { layers.forEach { $0.removeFromSuperlayer() } }
        barLayers.removeAll()

        // Create new layers matrix [series][labelIndex]
        for s in series {
            var row: [CAShapeLayer] = []
            for _ in s.values {
                let l = CAShapeLayer()
                l.fillColor = s.color.withAlphaComponent(0.95).cgColor
                layer.addSublayer(l)
                row.append(l)
            }
            barLayers.append(row)
        }
    }

    private func rebuildLabels() {
        labelViews.forEach { $0.removeFromSuperview() }
        labelViews = labels.map { t in
            let l = UILabel()
            l.translatesAutoresizingMaskIntoConstraints = false
            l.text = t
            l.font = labelFont
            l.textColor = labelColor
            l.textAlignment = .center
            addSubview(l)
            return l
        }
    }

    // MARK: - Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        guard !labels.isEmpty, !series.isEmpty else {
            baseline.path = nil
            return
        }

        // Resolve chart area (exclude label band)
        let labelBand: CGFloat = 14
        let rect = bounds.inset(by: contentInset)
        let barArea = CGRect(x: rect.minX,
                             y: rect.minY,
                             width: rect.width,
                             height: rect.height - labelBand)

        // Baseline right above labels
        let basePath = UIBezierPath()
        basePath.move(to: CGPoint(x: barArea.minX, y: barArea.maxY - 0.5))
        basePath.addLine(to: CGPoint(x: barArea.maxX, y: barArea.maxY - 0.5))
        baseline.path = basePath.cgPath

        // Global min/max across all series to normalize height
        var allValues: [Double] = []
        for s in series { allValues.append(contentsOf: s.values.prefix(labels.count)) }
        let maxV = max(allValues.max() ?? 1, 1)
        let minV = min(allValues.min() ?? 0, maxV)
        let range = max(maxV - minV, 0.0001)

        // Geometry
        let nSeries = series.count
        let groupWidth = CGFloat(nSeries) * barWidth + CGFloat(max(nSeries - 1, 0)) * barSpacing
        let totalWidth = CGFloat(labels.count) * groupWidth + CGFloat(max(labels.count - 1, 0)) * groupSpacing
        // Keep centered within barArea
        let startX = max(barArea.minX + (barArea.width - totalWidth)/2, barArea.minX)

        // Draw bars
        for (si, s) in series.enumerated() {
            for (i, v) in s.values.prefix(labels.count).enumerated() {
                let hRatio = CGFloat((v - minV) / range)
                let h = max(hRatio * (barArea.height - 2), 2)
                let gx = startX + CGFloat(i) * (groupWidth + groupSpacing)
                let x = gx + CGFloat(si) * (barWidth + barSpacing)
                let y = barArea.maxY - h
                let rect = CGRect(x: x, y: y, width: barWidth, height: h)
                let path = UIBezierPath(roundedRect: rect, cornerRadius: corner)
                barLayers[si][i].path = path.cgPath
                barLayers[si][i].fillColor = s.color.withAlphaComponent(0.95).cgColor
            }
        }

        // Position labels evenly under each group
        for (i, l) in labelViews.enumerated() {
            let gx = startX + CGFloat(i) * (groupWidth + groupSpacing)
            let centerX = gx + groupWidth/2
            let size = CGSize(width: max(groupWidth, 16), height: labelBand)
            l.frame = CGRect(x: centerX - size.width/2,
                             y: bounds.maxY - contentInset.bottom - labelBand,
                             width: size.width,
                             height: labelBand)
        }
    }

    // MARK: - API sugar
    public func setData(labels: [String], series: [ChartSeries]) {
        self.labels = labels
        self.series = series
    }
}
