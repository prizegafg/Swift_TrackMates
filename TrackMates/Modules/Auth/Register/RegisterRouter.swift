//
//  RegisterRouter.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import UIKit

protocol RegisterRouterProtocol {
    func navigateToLogin(from view: UIViewController)
}

final class RegisterRouter: RegisterRouterProtocol {
    func navigateToLogin(from view: UIViewController) {
        if let nav = view.navigationController {
            if let loginVC = nav.viewControllers.first(where: { $0 is LoginView }) {
                nav.popToViewController(loginVC, animated: true)
                return
            }
            if nav.viewControllers.count <= 1 {
                if nav.presentingViewController != nil {
                    nav.dismiss(animated: true)
                    return
                } else {
                    resetRootToLogin()
                    return
                }
            }
            _ = nav.popViewController(animated: true)
            return
        }
        resetRootToLogin()
    }
    private func resetRootToLogin() {
        let login = LoginRouter.makeModule()
        guard let ws = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let win = ws.windows.first else { return }
        win.setRoot(login, animated: true)
    }
}

extension RegisterRouter {
    static func makeModule() -> UIViewController {
        let interactor = RegisterInteractor()
        let router = RegisterRouter()
        let presenter = RegisterPresenter(interactor: interactor, router: router)

        let view = RegisterView()
        view.presenter = presenter
        return view
    }
}

