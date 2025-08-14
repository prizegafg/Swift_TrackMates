//
//  TrackingView.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import UIKit

final class TrackingView: UIViewController, TrackingViewProtocol {
    var presenter: TrackingPresenterProtocol!

    // MARK: - UI
    private enum UIK { static let side: CGFloat = 22 }

    // Header
    private let titleLbl: UILabel = {
        let l = UILabel()
        l.text = "RUNNING"
        l.font = .systemFont(ofSize: 16, weight: .heavy)
        l.textAlignment = .center
        l.textColor = .tmLabelPrimary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let optsBtn: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        b.tintColor = .tmLabelPrimary
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    private let backBtn: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        b.tintColor = .tmLabelPrimary
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // Stats card
    private let card = DSCard()
    private let bigDistance = UILabel()
    private let grid = UIStackView()
    private let paceView    = MetricItemView(title: "Avg. Pace")
    private let calView     = MetricItemView(title: "Calories")
    private let elevView    = MetricItemView(title: "Elevation Gain")
    private let bpmView     = MetricItemView(title: "Heart Rate")

    private let timeLbl: UILabel = {
        let l = UILabel()
        l.font = .monospacedDigitSystemFont(ofSize: 28, weight: .heavy)
        l.textAlignment = .center
        l.textColor = .tmLabelPrimary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // Controls
    private let btnLeft   = UIButton(type: .system)   // stop
    private let btnCenter = UIButton(type: .system)   // pause/play
    private let btnRight  = UIButton(type: .system)   // gps/status
    private let controlRow = UIStackView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .tmBackground

        buildUI()
        layoutUI()
        bindActions()

        presenter.attach(view: self)
        presenter.viewDidLoad()
    }

    // MARK: - TrackingViewProtocol
    var vc: UIViewController { self }

    func render(_ vm: TrackingVM) {
        bigDistance.text = vm.distanceText
        setMetric(tag: 101, value: vm.paceText)
        setMetric(tag: 102, value: vm.caloriesText)
        setMetric(tag: 103, value: vm.elevText)
        setMetric(tag: 104, value: vm.bpmText)
        timeLbl.text = vm.timeText
        let icon = vm.isPaused ? "play.fill" : "pause.fill"
        btnCenter.setImage(UIImage(systemName: icon), for: .normal)
    }

    func showPermissionHint() {
        let a = UIAlertController(title: "Location Permission Needed",
                                  message: "Allow location to track your run.", preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }

    func closeAfterSaved() { dismiss(animated: true) }

    func showError(_ msg: String) {
        let a = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}

// MARK: - Build
private extension TrackingView {
    func buildUI() {
        buildHeader()
        buildStatsCard()
        buildControls()
    }

    func buildHeader() {
        view.addSubview(backBtn)
        view.addSubview(titleLbl)
        view.addSubview(optsBtn)
    }

    func buildStatsCard() {
        [card, bigDistance, grid, timeLbl].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        bigDistance.font = .systemFont(ofSize: 48, weight: .heavy)
        bigDistance.textColor = .tmLabelPrimary
        bigDistance.textAlignment = .center

        grid.axis = .vertical
        grid.alignment = .fill
        grid.distribution = .fillEqually
        grid.spacing = 10

        // tag utk binding presenter
        paceView.tag = 101; calView.tag = 102; elevView.tag = 103; bpmView.tag = 104

        let row1 = row()
        row1.addArrangedSubview(paceView)
        row1.addArrangedSubview(calView)

        let row2 = row()
        row2.addArrangedSubview(elevView)
        row2.addArrangedSubview(bpmView)

        grid.addArrangedSubview(row1)
        grid.addArrangedSubview(row2)

        view.addSubview(card)
        card.addSubview(bigDistance)
        card.addSubview(grid)
        view.addSubview(timeLbl)
    }

    func buildControls() {
        [btnLeft, btnCenter, btnRight].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .tmCardBackground
            $0.tintColor = .tmLabelPrimary
            $0.widthAnchor.constraint(equalToConstant: 60).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 60).isActive = true
            $0.layer.cornerRadius = 30
        }
        btnLeft.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        btnCenter.setImage(UIImage(systemName: "play.fill"), for: .normal)
        btnRight.setImage(UIImage(systemName: "location.fill"), for: .normal)

        controlRow.axis = .horizontal
        controlRow.alignment = .center
        controlRow.spacing = 28
        controlRow.translatesAutoresizingMaskIntoConstraints = false
        [btnLeft, btnCenter, btnRight].forEach { controlRow.addArrangedSubview($0) }
        view.addSubview(controlRow)
    }
}

// MARK: - Layout
private extension TrackingView {
    func layoutUI() {
        layoutHeader()
        layoutStatsCard()
        layoutControls()
    }

    func layoutHeader() {
        NSLayoutConstraint.activate([
            backBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIK.side),
            backBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),

            optsBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIK.side),
            optsBtn.centerYAnchor.constraint(equalTo: backBtn.centerYAnchor),

            titleLbl.centerYAnchor.constraint(equalTo: backBtn.centerYAnchor),
            titleLbl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    func layoutStatsCard() {
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 16),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIK.side),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIK.side),

            bigDistance.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            bigDistance.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            bigDistance.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            grid.topAnchor.constraint(equalTo: bigDistance.bottomAnchor, constant: 12),
            grid.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            grid.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            grid.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),

            timeLbl.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 16),
            timeLbl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    func layoutControls() {
        NSLayoutConstraint.activate([
            controlRow.topAnchor.constraint(equalTo: timeLbl.bottomAnchor, constant: 18),
            controlRow.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
}

// MARK: - Helpers & Actions
private extension TrackingView {
    func row() -> UIStackView {
        let r = UIStackView()
        r.axis = .horizontal
        r.alignment = .fill
        r.distribution = .fillEqually
        r.spacing = 10
        r.translatesAutoresizingMaskIntoConstraints = false
        return r
    }

    func setMetric(tag: Int, value: String) {
        if let v = view.viewWithTag(tag) as? MetricItemView {
            v.set(value)
        }
    }

    func bindActions() {
        backBtn.addTarget(self, action: #selector(closeTap), for: .touchUpInside)
        btnCenter.addTarget(self, action: #selector(pauseResume), for: .touchUpInside)
        btnLeft.addTarget(self, action: #selector(stopTap), for: .touchUpInside)
    }

    @objc func closeTap()    { dismiss(animated: true) }
    @objc func pauseResume() { presenter.tapPauseResume() }
    @objc func stopTap() {                   
        let a = UIAlertController(title: "Finish run?",
                                  message: "Do you want to save and finish this session?",
                                  preferredStyle: .actionSheet)
        a.addAction(UIAlertAction(title: "Finish & Save", style: .destructive) { [weak self] _ in
            self?.presenter.tapStop()
        })
        a.addAction(UIAlertAction(title: "Continue", style: .cancel))
        present(a, animated: true)
    }
}
