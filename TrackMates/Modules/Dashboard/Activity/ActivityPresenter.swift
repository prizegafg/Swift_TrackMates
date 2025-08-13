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
    func setQuickActions(_ titles: [String])      // ["Run","Walk","Bike"]
    func renderRecent(_ vm: RecentActivityVM)      // mock summary
}

// MARK: - Presenter Contracts
protocol ActivityPresenterProtocol: AnyObject {
    func attach(view: ActivityViewProtocol)
    func viewDidLoad()
    func startRun(from vc: UIViewController)
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
    }
    
    func startRun(from vc: UIViewController) {
        router.presentRun(from: vc)
    }
}
