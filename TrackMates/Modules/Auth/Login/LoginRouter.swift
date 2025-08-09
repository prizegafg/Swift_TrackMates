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
        // Buat HomeViewController dengan user, lalu push atau present
        // Contoh:
        // let homeVC = HomeViewController(user: user)
        // view.navigationController?.setViewControllers([homeVC], animated: true)
    }

    func navigateToRegister(from view: UIViewController) {
        // let registerVC = RegisterViewController()
        // view.present(registerVC, animated: true)
    }
}

extension LoginRouter {
    static func makeModule() -> UIViewController {
        let interactor = LoginInteractor()
        let presenter = LoginPresenter(interactor: interactor)
        let view = Login()
        view.presenter = presenter
        let nav = UINavigationController(rootViewController: view)
        nav.navigationBar.isTranslucent = false
        nav.navigationBar.prefersLargeTitles = false
        return nav
    }
}
