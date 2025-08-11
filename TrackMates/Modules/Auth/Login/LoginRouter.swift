//
//  LoginRouter.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import UIKit

protocol LoginRouterProtocol {
    func navigateToHome(from view: UIViewController, user: UserEntity)
    func navigateToRegister(from view: UIViewController)
}

final class LoginRouter: LoginRouterProtocol {
    func navigateToHome(from view: UIViewController, user: UserEntity) {
        SessionManager.shared.didLogin()
    }

    func navigateToRegister(from view: UIViewController) {
        let registerVC = RegisterRouter.makeModule()
        if let nav = view.navigationController {
            nav.setNavigationBarHidden(true, animated: false)
            nav.pushViewController(registerVC, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: registerVC)
            nav.setNavigationBarHidden(true, animated: false) // ✅ hidden
            nav.modalPresentationStyle = .fullScreen
            view.present(nav, animated: true)
        }
    }
}

extension LoginRouter {
    static func makeModule() -> UIViewController {
        let interactor = LoginInteractor()
        let router = LoginRouter()
        let presenter = LoginPresenter(interactor: interactor, router: router) 

        let view = LoginView()
        view.presenter = presenter
        
        let nav = UINavigationController(rootViewController: view)
        nav.setNavigationBarHidden(true, animated: false)
        nav.modalPresentationStyle = .fullScreen
        return nav
    }
}

