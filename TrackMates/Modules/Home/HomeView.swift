//
//  HomeView.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import UIKit
import Combine

struct HomeHeaderVM {
    let greeting: String   // e.g. "Good Morning,"
    let name: String       // e.g. "Andy"
}

struct HomeStatsVM {
    let title: String      // "Running last week"
    let totalText: String  // "48.75 KM"
    let deltaText: String  // "↑ 12% vs last week"
    let series: [Double]   // sparkline points
}


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

    // “Story IG” row (hidden now but siap dipakai)
    private let storiesContainer = UIView()
    private var storiesH: NSLayoutConstraint!

    private let statsCard = DSCard()
    private let statsTitle = UILabel()
    private let statsTotal = UILabel()
    private let statsDelta = UILabel()
    private let spark = SparklineView()

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
        spark.values = stats.series
    }
}

// MARK: - UI
private extension HomeView {
    func buildUI() {
        [scroll, topBar].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        [content, titleLabel, logoutBtn, greetingLabel, storiesContainer, statsCard].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        [statsTitle, statsTotal, statsDelta, spark].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        view.addSubview(topBar)
        view.addSubview(scroll)
        scroll.addSubview(content)

        // top bar
        topBar.addSubview(titleLabel)
        topBar.addSubview(logoutBtn)
        view.addSubview(greetingLabel)

        // stories (hidden)
        storiesContainer.backgroundColor = .clear
        storiesH = storiesContainer.heightAnchor.constraint(equalToConstant: 0) // hidden: height 0
        storiesH.isActive = true
        content.addSubview(storiesContainer)

        // stats card
        statsTitle.font = .systemFont(ofSize: 13, weight: .medium)
        statsTitle.textColor = .tmLabelSecondary
        statsTotal.font = .systemFont(ofSize: 28, weight: .bold)
        statsTotal.textColor = .tmLabelPrimary
        statsDelta.font = .systemFont(ofSize: 12, weight: .semibold)
        statsDelta.textColor = .tmSuccess

        statsCard.addSubview(statsTitle)
        statsCard.addSubview(statsTotal)
        statsCard.addSubview(statsDelta)
        statsCard.addSubview(spark)
        content.addSubview(statsCard)
    }

    func layoutUI() {
        NSLayoutConstraint.activate([
            // top bar + greeting
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

            // scroll
            scroll.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: UI.big),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            content.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor),

            // stories (hidden sekarang)
            storiesContainer.topAnchor.constraint(equalTo: content.topAnchor),
            storiesContainer.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: UI.side),
            storiesContainer.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -UI.side),

            // stats card
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

            spark.topAnchor.constraint(equalTo: statsTotal.bottomAnchor, constant: 14),
            spark.leadingAnchor.constraint(equalTo: statsTitle.leadingAnchor),
            spark.trailingAnchor.constraint(equalTo: statsCard.trailingAnchor, constant: -16),
            spark.heightAnchor.constraint(equalToConstant: 64),
            spark.bottomAnchor.constraint(equalTo: statsCard.bottomAnchor, constant: -16),

            // content bottom
            statsCard.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -24)
        ])
    }

    func bindActions() {
        logoutBtn.addTarget(self, action: #selector(tapLogout), for: .touchUpInside)
    }

    @objc func tapLogout() { presenter.onTapLogout() }
}
