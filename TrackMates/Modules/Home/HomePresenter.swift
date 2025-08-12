//
//  HomePresenter.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import UIKit

protocol HomeViewProtocol: AnyObject {
    var vc: UIViewController { get }
    func showError(_ message: String)
}

protocol HomePresenterProtocol: AnyObject {
    func attach(view: HomeViewProtocol)
    func onTapLogout()
}

final class HomePresenter: HomePresenterProtocol {
    private weak var view: HomeViewProtocol?
    private let interactor: HomeInteractorProtocol
    private let router: HomeRouterProtocol

    init(interactor: HomeInteractorProtocol, router: HomeRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    func attach(view: HomeViewProtocol) { self.view = view }

    func onTapLogout() {
        interactor.logout { [weak self] result in
            switch result {
            case .success:
                self?.router.resetToLogin()
            case .failure(let error):
                self?.view?.showError(error.localizedDescription)
            }
        }
    }
}
