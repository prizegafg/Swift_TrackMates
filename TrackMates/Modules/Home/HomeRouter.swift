//
//  HomeRouter.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import UIKit

protocol HomeRouterProtocol: AnyObject {
    func resetToLogin()
}

final class HomeRouter: HomeRouterProtocol {
    func resetToLogin() {
        let login = LoginRouter.makeModule()
        guard let ws = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let win = ws.windows.first else { return }
        win.setRoot(login, animated: true) // pakai helper yang sudah ada
    }
}

extension HomeRouter {
    static func makeModule() -> UIViewController {
        let interactor = HomeInteractor()
        let router = HomeRouter()
        let presenter = HomePresenter(interactor: interactor, router: router)
        let view = HomeView()
        view.presenter = presenter
        presenter.attach(view: view)

        let nav = UINavigationController(rootViewController: view)
        return nav
    }
}
