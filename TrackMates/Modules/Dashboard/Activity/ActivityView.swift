//
//  ActivityView.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 13/08/25.
//

import UIKit

final class ActivityView: UIViewController, ActivityViewProtocol {
    var presenter: ActivityPresenterProtocol!

    private enum UIK {
        static let side: CGFloat = 20
        static let v: CGFloat = 12
        static let big: CGFloat = 22
        static let btnH: CGFloat = 56   // ⬅️ tinggi tombol diperbesar
    }

    // Title
    private let titleLbl: UILabel = {
        let l = UILabel()
        l.text = "Activity"
        l.font = .systemFont(ofSize: 28, weight: .bold)
        l.textColor = .tmLabelPrimary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // Quick Actions
    private let qaContainer = UIView()
    private let rowTop = UIStackView()
    private let runBtn = DesignButton.primary("Run")
    private let walkBtn = DesignButton.primary("Walk")
    private let bikeBtn = DesignButton.primary("Bike")

    // Recent Card
    private let recentCard = DSCard()
    private let recentTitle: UILabel = {
        let l = UILabel()
        l.text = "Recent"
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = .tmLabelSecondary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let distanceLbl: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 36, weight: .bold)
        l.textColor = .tmLabelPrimary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let durationLbl: UILabel = {
        let l = UILabel()
        l.font = .monospacedDigitSystemFont(ofSize: 18, weight: .semibold)
        l.textColor = .tmLabelPrimary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let metricsRow = UIStackView()
    private let chart = SparklineView()

    private let activityCard = DSCard()
    private let activityTitle: UILabel = {
        let l = UILabel()
        l.text = "Your Activity"
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = .tmLabelSecondary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let activityList = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .tmBackground

        buildUI()
        layoutUI()
        setUpAction()
        presenter.viewDidLoad()
    }

    // MARK: - ActivityViewProtocol
    func setTitle(_ t: String) { titleLbl.text = t }

    func setQuickActions(_ titles: [String]) {
        if titles.indices.contains(0) { runBtn.setTitle(titles[0], for: .normal) }
        if titles.indices.contains(1) { walkBtn.setTitle(titles[1], for: .normal) }
        if titles.indices.contains(2) { bikeBtn.setTitle(titles[2], for: .normal) }
    }

    func renderRecent(_ vm: RecentActivityVM) {
        distanceLbl.text = vm.distanceText
        durationLbl.text = vm.durationText
        metricsRow.arrangedSubviews.forEach { $0.removeFromSuperview() }
        metricsRow.addArrangedSubview(metric("Calories", vm.caloriesText))
        metricsRow.addArrangedSubview(metric("Heart Rate", vm.heartRateText))
        metricsRow.addArrangedSubview(metric("Elevation", vm.elevationText))
        chart.values = vm.sparkline
    }
    
    func renderSummary(_ vm: ActivitySummaryVM) {
        activityTitle.text = vm.title
        activityList.arrangedSubviews.forEach { $0.removeFromSuperview() }
        vm.items.forEach { item in
            activityList.addArrangedSubview(StatRow(title: item.title, value: item.value, icon: item.icon))
        }
    }
}

// MARK: - UI
private extension ActivityView {
    func buildUI() {
        [qaContainer, recentCard].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        // Top row (Run + Walk)
        rowTop.axis = .horizontal
        rowTop.alignment = .fill
        rowTop.distribution = .fillEqually
        rowTop.spacing = 12
        rowTop.translatesAutoresizingMaskIntoConstraints = false

        // Buttons height & padding
        [runBtn, walkBtn, bikeBtn].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.heightAnchor.constraint(equalToConstant: UIK.btnH).isActive = true
            $0.contentEdgeInsets = .init(top: 0, left: 14, bottom: 0, right: 14)
        }

        // ⬇️ Tambah ikon untuk tiap tombol
        applyIcon("figure.run",  to: runBtn)
        applyIcon("figure.walk", to: walkBtn)
        applyIcon("bicycle",     to: bikeBtn)

        // Recent metrics row
        metricsRow.axis = .horizontal
        metricsRow.alignment = .center
        metricsRow.distribution = .fillEqually
        metricsRow.spacing = 12
        metricsRow.translatesAutoresizingMaskIntoConstraints = false

        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.lineWidth = 2
        chart.fill = true

        view.addSubview(titleLbl)
        view.addSubview(qaContainer)
        view.addSubview(recentCard)

        qaContainer.addSubview(rowTop)
        qaContainer.addSubview(bikeBtn)

        rowTop.addArrangedSubview(runBtn)
        rowTop.addArrangedSubview(walkBtn)

        recentCard.addSubview(recentTitle)
        recentCard.addSubview(distanceLbl)
        recentCard.addSubview(durationLbl)
        recentCard.addSubview(metricsRow)
        recentCard.addSubview(chart)
        
        activityList.axis = .vertical
        activityList.alignment = .fill
        activityList.distribution = .fill
        activityList.spacing = 10
        activityList.translatesAutoresizingMaskIntoConstraints = false
        
        activityCard.addSubview(activityTitle)
        activityCard.addSubview(activityList)
        view.addSubview(activityCard)
    }

    func layoutUI() {
        NSLayoutConstraint.activate([
            // Title
            titleLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIK.side),
            titleLbl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),

            // Quick Actions container
            qaContainer.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: UIK.big),
            qaContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIK.side),
            qaContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIK.side),

            // Run + Walk (setengah lebar, sejajar)
            rowTop.topAnchor.constraint(equalTo: qaContainer.topAnchor),
            rowTop.leadingAnchor.constraint(equalTo: qaContainer.leadingAnchor),
            rowTop.trailingAnchor.constraint(equalTo: qaContainer.trailingAnchor),

            // Bike (setengah lebar, ⬅️ kiri)
            bikeBtn.topAnchor.constraint(equalTo: rowTop.bottomAnchor, constant: 12),
            bikeBtn.leadingAnchor.constraint(equalTo: qaContainer.leadingAnchor), // ⬅️ kiri
            bikeBtn.widthAnchor.constraint(equalTo: qaContainer.widthAnchor, multiplier: 0.5),

            // qaContainer bottom
            bikeBtn.bottomAnchor.constraint(equalTo: qaContainer.bottomAnchor),

            // Recent card (ada jarak dari buttons)
            recentCard.topAnchor.constraint(equalTo: qaContainer.bottomAnchor, constant: UIK.big),
            recentCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIK.side),
            recentCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIK.side),
        ])

        NSLayoutConstraint.activate([
            recentTitle.topAnchor.constraint(equalTo: recentCard.topAnchor, constant: 16),
            recentTitle.leadingAnchor.constraint(equalTo: recentCard.leadingAnchor, constant: 16),
            recentTitle.trailingAnchor.constraint(lessThanOrEqualTo: recentCard.trailingAnchor, constant: -16),

            distanceLbl.topAnchor.constraint(equalTo: recentTitle.bottomAnchor, constant: 6),
            distanceLbl.leadingAnchor.constraint(equalTo: recentTitle.leadingAnchor),

            durationLbl.centerYAnchor.constraint(equalTo: distanceLbl.centerYAnchor),
            durationLbl.trailingAnchor.constraint(equalTo: recentCard.trailingAnchor, constant: -16),

            metricsRow.topAnchor.constraint(equalTo: distanceLbl.bottomAnchor, constant: 8),
            metricsRow.leadingAnchor.constraint(equalTo: recentTitle.leadingAnchor),
            metricsRow.trailingAnchor.constraint(equalTo: recentCard.trailingAnchor, constant: -16),

            chart.topAnchor.constraint(equalTo: metricsRow.bottomAnchor, constant: 10),
            chart.leadingAnchor.constraint(equalTo: recentTitle.leadingAnchor),
            chart.trailingAnchor.constraint(equalTo: recentCard.trailingAnchor, constant: -16),
            chart.heightAnchor.constraint(equalToConstant: 72),
            chart.bottomAnchor.constraint(equalTo: recentCard.bottomAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            activityCard.topAnchor.constraint(equalTo: recentCard.bottomAnchor, constant: UIK.big),
            activityCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIK.side),
            activityCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIK.side),
            
            activityTitle.topAnchor.constraint(equalTo: activityCard.topAnchor, constant: 16),
            activityTitle.leadingAnchor.constraint(equalTo: activityCard.leadingAnchor, constant: 16),
            activityTitle.trailingAnchor.constraint(lessThanOrEqualTo: activityCard.trailingAnchor, constant: -16),
            
            activityList.topAnchor.constraint(equalTo: activityTitle.bottomAnchor, constant: 10),
            activityList.leadingAnchor.constraint(equalTo: activityCard.leadingAnchor, constant: 12),
            activityList.trailingAnchor.constraint(equalTo: activityCard.trailingAnchor, constant: -12),
            activityList.bottomAnchor.constraint(equalTo: activityCard.bottomAnchor, constant: -12),
        ])
    }

    func metric(_ title: String, _ value: String) -> UIStackView {
        let name = UILabel()
        name.text = title
        name.font = .systemFont(ofSize: 11, weight: .regular)
        name.textColor = .tmLabelSecondary

        let val = UILabel()
        val.text = value
        val.font = .systemFont(ofSize: 13, weight: .semibold)
        val.textColor = .tmLabelPrimary

        let v = UIStackView(arrangedSubviews: [name, val])
        v.axis = .vertical
        v.alignment = .leading
        v.spacing = 2
        return v
    }

    // Helper kecil untuk pasang ikon kiri + spasi rapi
    func applyIcon(_ systemName: String, to button: UIButton) {
        let img = UIImage(systemName: systemName)
        button.setImage(img, for: .normal)
        button.tintColor = .tmLabelInverse
        button.semanticContentAttribute = .forceLeftToRight
        // sedikit jarak antara ikon dan teks
        button.titleEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: -8)
        button.imageView?.contentMode = .scaleAspectFit
        // accessibility
        button.accessibilityTraits.insert(.button)
    }
}

extension ActivityView {
    func setUpAction() {
        runBtn.addTarget(self, action: #selector(runTap),  for: .touchUpInside)
        walkBtn.addTarget(self, action: #selector(walkTap), for: .touchUpInside)
        bikeBtn.addTarget(self, action: #selector(bikeTap), for: .touchUpInside)
    }
    
    @objc private func runTap()  { presenter.startActivity(from: self, mode: .run)  }
    @objc private func walkTap() { presenter.startActivity(from: self, mode: .walk) }
    @objc private func bikeTap() { presenter.startActivity(from: self, mode: .bike) }

}

