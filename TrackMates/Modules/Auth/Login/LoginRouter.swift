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
            nav.pushViewController(registerVC, animated: true)
        } else {
            view.present(UINavigationController(rootViewController: registerVC), animated: true)
        }
    }
}

extension LoginRouter {
    static func makeModule() -> UIViewController {
        let interactor = LoginInteractor()
        let router = LoginRouter()
        let presenter = LoginPresenter(interactor: interactor, router: router) 

        let view = Login()
        view.presenter = presenter
        
        let nav = UINavigationController(rootViewController: view)
        nav.navigationBar.isTranslucent = false
        nav.navigationBar.prefersLargeTitles = false
        return nav
    }
}

