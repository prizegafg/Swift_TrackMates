//
//  ActivityPresenter.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 13/08/25.
//

import UIKit

// MARK: - View Contracts
protocol ActivityViewProtocol: AnyObject {
    func setTitle(_ t: String)
    func setQuickActions(_ titles: [String])
    func renderRecent(_ vm: RecentActivityVM)
    func renderSummary(_ vm: ActivitySummaryVM)
}

// MARK: - Presenter Contracts
protocol ActivityPresenterProtocol: AnyObject {
    func attach(view: ActivityViewProtocol)
    func viewDidLoad()
    func startActivity(from vc: UIViewController, mode: TrackingMode)
}

// MARK: - View Models
struct RecentActivityVM {
    let distanceText: String     // e.g. "8.31 KM"
    let caloriesText: String     // e.g. "313 Kcal"
    let heartRateText: String    // e.g. "126 Bpm"
    let elevationText: String    // e.g. "4.1 m"
    let durationText: String     // e.g. "00:30:20"
    let sparkline: [Double]      // small chart values
}

struct ActivitySummaryItemVM {
    let title: String        // ex: "Today"
    let value: String        // ex: "5.72 KM"
    let icon: String         // SF Symbols name, ex: "sun.max.fill"
}

struct ActivitySummaryVM {
    let title: String        // ex: "Your Activity"
    let items: [ActivitySummaryItemVM]
}

// MARK: - Presenter
final class ActivityPresenter: ActivityPresenterProtocol {
    private weak var view: ActivityViewProtocol?
    private let interactor: ActivityInteractorProtocol
    private let router: ActivityRouterProtocol

    init(interactor: ActivityInteractorProtocol, router: ActivityRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }
    func attach(view: ActivityViewProtocol) { self.view = view }

    func viewDidLoad() {
        view?.setTitle("Activity")
        view?.setQuickActions(["Run","Walk","Bike"])

        // Mock recent data (ringan & cukup untuk UI)
        let vm = RecentActivityVM(
            distanceText: "8.31 KM",
            caloriesText: "313 Kcal",
            heartRateText: "126 Bpm",
            elevationText: "4.1 m",
            durationText: "00:30:20",
            sparkline: [0.1,0.6,0.35,0.8,0.55,0.9,0.7]
        )
        view?.renderRecent(vm)
        
        let summary = ActivitySummaryVM(
            title: "Your Activity",
            items: [
                .init(title: "Today",      value: "5.72 KM",       icon: "sun.max.fill"),
                .init(title: "Yesterday",  value: "12,876 Steps",  icon: "clock.fill"),
                .init(title: "Last Week",  value: "19.8 KM",       icon: "calendar")
            ]
        )
        view?.renderSummary(summary)
    }
    
    func startActivity(from vc: UIViewController, mode: TrackingMode) {
        router.presentTracking(from: vc, mode: mode)
    }
}
