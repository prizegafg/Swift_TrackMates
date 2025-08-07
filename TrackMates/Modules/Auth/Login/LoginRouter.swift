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
