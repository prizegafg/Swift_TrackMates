//
//  HomePresenter.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import UIKit
import Combine

protocol HomeViewProtocol: AnyObject {
    var vc: UIViewController { get }
    func showError(_ message: String)
    func render(header: HomeHeaderVM)
    func render(stats: HomeStatsVM)
    func render(rank: [RankItemVM])
    func render(chart: HomeChartVM)
}

protocol HomePresenterProtocol: AnyObject {
    func attach(view: HomeViewProtocol)
    func viewDidLoad()
    func onTapLogout()
}

final class HomePresenter: HomePresenterProtocol {
    private weak var view: HomeViewProtocol?
    private let interactor: HomeInteractorProtocol
    private let router: HomeRouterProtocol
    private var bag = Set<AnyCancellable>()

    init(interactor: HomeInteractorProtocol, router: HomeRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    func attach(view: HomeViewProtocol) { self.view = view }

    func viewDidLoad() {
        interactor.loadHeader { [weak self] res in
            if case .success(let vm) = res { self?.view?.render(header: vm) }
        }
        interactor.loadWeeklyStats { [weak self] res in
            if case .success(let vm) = res { self?.view?.render(stats: vm) }
        }
        interactor.loadWeeklyRank { [weak self] res in         
            if case .success(let items) = res { self?.view?.render(rank: items) }
        }
        interactor.loadWeeklyChart { [weak self] res in
            if case .success(let vm) = res { self?.view?.render(chart: vm) }
        }
    }

    func onTapLogout() {
        interactor.logout { [weak self] result in
            switch result {
            case .success: self?.router.resetToLogin()
            case .failure(let error): self?.view?.showError(error.localizedDescription)
            }
        }
    }
}

