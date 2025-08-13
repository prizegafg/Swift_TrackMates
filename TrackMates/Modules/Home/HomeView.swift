//
//  HomeView.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import UIKit
import Combine


final class HomeView: UIViewController, HomeViewProtocol {
    var presenter: HomePresenterProtocol!
    var vc: UIViewController { self }
    private var bag = Set<AnyCancellable>()

    // MARK: - UI constants
    private enum UI {
        static let side: CGFloat = 20
        static let v: CGFloat = 12
        static let big: CGFloat = 22
        static let storyH: CGFloat = 72
    }

    // MARK: - Views
    private let scroll = UIScrollView()
    private let content = UIView()

    private let topBar = UIView()
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Home"
        l.font = .systemFont(ofSize: 28, weight: .bold)
        l.textColor = .tmLabelPrimary
        return l
    }()
    private let logoutBtn: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.right"), for: .normal)
        b.tintColor = .tmLabelPrimary
        b.accessibilityLabel = "Logout"
        return b
    }()

    private let greetingLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.textColor = .tmLabelSecondary
        l.text = "Good Morning, Runner"
        return l
    }()

    private let storiesContainer = UIView()
    private var storiesH: NSLayoutConstraint!

    private let statsCard = DSCard()
    private let statsTitle = UILabel()
    private let statsTotal = UILabel()
    private let statsDelta = UILabel()
    private let chart = GroupedBarChartView()
    private let legend = ChartLegendView()
    private let rankCard = DSCard()
    private let rankTitle = UILabel()
    private let rankList = RankListView()

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .tmBackground
        buildUI()
        layoutUI()
        bindActions()
        presenter.viewDidLoad()
    }

    // MARK: - ViewProtocol
    func showError(_ message: String) {
        let a = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }

    func render(header: HomeHeaderVM) {
        greetingLabel.text = "\(header.greeting) \(header.name)"
    }
    
    func render(stats: HomeStatsVM) {
        statsTitle.text = stats.title
        statsTotal.text = stats.totalText
        statsDelta.text = stats.deltaText
    }
    func render(rank: [RankItemVM]) { rankList.items = rank }
    
    func render(chart vm: HomeChartVM) {
        // warna: biru = run, oranye = ride, kuning = walk
        let runColor  = UIColor.tmTint
        let rideColor = UIColor.systemOrange
        let walkColor = UIColor(hex: 0xFACC15)
        
        var items: [LegendItem] = []
        var series: [ChartSeries] = []
        
        if vm.run.contains(where: { $0 > 0 }) {
            series.append(.init(color: runColor,  values: vm.run))
            items.append(.init(color: runColor, text: "Run"))
        }
        if vm.ride.contains(where: { $0 > 0 }) {
            series.append(.init(color: rideColor, values: vm.ride))
            items.append(.init(color: rideColor, text: "Ride"))
        }
        if vm.walk.contains(where: { $0 > 0 }) {
            series.append(.init(color: walkColor, values: vm.walk))
            items.append(.init(color: walkColor, text: "Walk"))
        }
        
        chart.contentInset = .init(top: 6, left: 16, bottom: 22, right: 16) // ada jeda kiri-kanan
        chart.groupSpacing = 16
        chart.barWidth = 8
        chart.barSpacing = 4
        chart.setData(labels: vm.days, series: series)
        legend.items = items
    }
}

// MARK: - UI
private extension HomeView {
    func buildUI() {
        [scroll, topBar].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        [content, titleLabel, logoutBtn, greetingLabel, storiesContainer, statsCard].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        [statsTitle, statsTotal, statsDelta, chart, legend].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        view.addSubview(topBar)
        view.addSubview(scroll)
        scroll.addSubview(content)

        // top bar
        topBar.addSubview(titleLabel)
        topBar.addSubview(logoutBtn)
        view.addSubview(greetingLabel)

        // stories (hidden)
        content.addSubview(storiesContainer)
        storiesH = storiesContainer.heightAnchor.constraint(equalToConstant: 0)
        storiesH.isActive = true
        
        statsTitle.font = .systemFont(ofSize: 13, weight: .medium)
        statsTitle.textColor = .tmLabelSecondary
        statsTotal.font = .systemFont(ofSize: 28, weight: .bold)
        statsTotal.textColor = .tmLabelPrimary
        statsDelta.font = .systemFont(ofSize: 12, weight: .semibold)
        statsDelta.textColor = .tmSuccess
        statsCard.addSubview(statsTitle)
        statsCard.addSubview(statsTotal)
        statsCard.addSubview(statsDelta)
        statsCard.addSubview(chart)
        statsCard.addSubview(legend)
        content.addSubview(statsCard)
        
        // rank card
        rankTitle.translatesAutoresizingMaskIntoConstraints = false
        rankList.translatesAutoresizingMaskIntoConstraints = false
        rankTitle.text = "Weekly Activity Rank"
        rankTitle.font = .systemFont(ofSize: 13, weight: .medium)
        rankTitle.textColor = .tmLabelSecondary
        rankCard.addSubview(rankTitle)
        rankCard.addSubview(rankList)
        content.addSubview(rankCard)
    }

    func layoutUI() {
        NSLayoutConstraint.activate([
            
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UI.side),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UI.side),

            titleLabel.topAnchor.constraint(equalTo: topBar.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: topBar.leadingAnchor),
            logoutBtn.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            logoutBtn.trailingAnchor.constraint(equalTo: topBar.trailingAnchor),

            greetingLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            greetingLabel.leadingAnchor.constraint(equalTo: topBar.leadingAnchor),
            greetingLabel.trailingAnchor.constraint(lessThanOrEqualTo: topBar.trailingAnchor),

            scroll.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: UI.big),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            content.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor),

            storiesContainer.topAnchor.constraint(equalTo: content.topAnchor),
            storiesContainer.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: UI.side),
            storiesContainer.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -UI.side),

            statsCard.topAnchor.constraint(equalTo: storiesContainer.bottomAnchor, constant: UI.big),
            statsCard.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: UI.side),
            statsCard.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -UI.side),

            statsTitle.topAnchor.constraint(equalTo: statsCard.topAnchor, constant: 16),
            statsTitle.leadingAnchor.constraint(equalTo: statsCard.leadingAnchor, constant: 16),
            statsTitle.trailingAnchor.constraint(lessThanOrEqualTo: statsCard.trailingAnchor, constant: -16),

            statsTotal.topAnchor.constraint(equalTo: statsTitle.bottomAnchor, constant: 6),
            statsTotal.leadingAnchor.constraint(equalTo: statsTitle.leadingAnchor),

            statsDelta.centerYAnchor.constraint(equalTo: statsTotal.centerYAnchor),
            statsDelta.trailingAnchor.constraint(equalTo: statsCard.trailingAnchor, constant: -16),

            chart.topAnchor.constraint(equalTo: statsTotal.bottomAnchor, constant: 14),
            chart.leadingAnchor.constraint(equalTo: statsTitle.leadingAnchor),
            chart.trailingAnchor.constraint(equalTo: statsCard.trailingAnchor, constant: -16),
            chart.heightAnchor.constraint(equalToConstant: 100),
            
            legend.topAnchor.constraint(equalTo: chart.bottomAnchor, constant: 8),
            legend.leadingAnchor.constraint(equalTo: chart.leadingAnchor),
            legend.trailingAnchor.constraint(lessThanOrEqualTo: chart.trailingAnchor),
            legend.heightAnchor.constraint(greaterThanOrEqualToConstant: 14),
            legend.bottomAnchor.constraint(equalTo: statsCard.bottomAnchor, constant: -16),
            
            // Rank card under chart
            rankCard.topAnchor.constraint(equalTo: statsCard.bottomAnchor, constant: UI.big),
            rankCard.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: UI.side),
            rankCard.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -UI.side),
            
            rankTitle.topAnchor.constraint(equalTo: rankCard.topAnchor, constant: 16),
            rankTitle.leadingAnchor.constraint(equalTo: rankCard.leadingAnchor, constant: 16),
            rankTitle.trailingAnchor.constraint(lessThanOrEqualTo: rankCard.trailingAnchor, constant: -16),
            
            rankList.topAnchor.constraint(equalTo: rankTitle.bottomAnchor, constant: 10),
            rankList.leadingAnchor.constraint(equalTo: rankCard.leadingAnchor),
            rankList.trailingAnchor.constraint(equalTo: rankCard.trailingAnchor),
            rankList.bottomAnchor.constraint(equalTo: rankCard.bottomAnchor, constant: -8),
            
            // bottom spacing for scroll
            rankCard.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -24)
        ])
    }

    func bindActions() {
        logoutBtn.addTarget(self, action: #selector(tapLogout), for: .touchUpInside)
    }

    @objc func tapLogout() { presenter.onTapLogout() }
}
