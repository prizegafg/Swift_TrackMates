//
//  ChallengeRouter.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 13/08/25.
//

import UIKit

protocol ChallengeRouterProtocol: AnyObject { }

final class ChallengeRouter: ChallengeRouterProtocol { }

extension ChallengeRouter {
    static func makeModule() -> UIViewController {
        let interactor = ChallengeInteractor()
        let router = ChallengeRouter()
        let presenter = ChallengePresenter(interactor: interactor, router: router)
        let view = ChallengeView()
        view.presenter = presenter
        presenter.attach(view: view)

        let nav = UINavigationController(rootViewController: view)
        nav.setNavigationBarHidden(true, animated: false)
        return nav
    }
}
