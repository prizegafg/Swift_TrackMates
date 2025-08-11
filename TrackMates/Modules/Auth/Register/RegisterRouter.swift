//
//  RegisterRouter.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import UIKit

protocol RegisterRouterProtocol {
    func navigateToHome(from view: UIViewController, user: UserEntity)
    func navigateToLogin(from view: UIViewController)
}

final class RegisterRouter: RegisterRouterProtocol {
    func navigateToLogin(from view: UIViewController) {
        if let nav = view.navigationController {
            nav.popViewController(animated: true)
        } else {
            let login = LoginRouter.makeModule()
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else { return }
            window.setRoot(login, animated: true)
        }
    }
    func navigateToHome(from view: UIViewController, user: UserEntity) { }
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

