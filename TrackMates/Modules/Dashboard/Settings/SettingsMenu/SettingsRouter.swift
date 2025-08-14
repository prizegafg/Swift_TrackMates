//
//  SettingsRouter.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 13/08/25.
//

import UIKit

protocol SettingsRouterProtocol: AnyObject { }

final class SettingsRouter: SettingsRouterProtocol { }

extension SettingsRouter {
    static func makeModule() -> UIViewController {
        let interactor = SettingsInteractor()
        let router     = SettingsRouter()
        let presenter  = SettingsPresenter(interactor: interactor, router: router)
        let view       = SettingsView()
        view.presenter = presenter
        presenter.attach(view: view)

        let nav = UINavigationController(rootViewController: view)
        nav.setNavigationBarHidden(true, animated: false)
        return nav
    }
}
