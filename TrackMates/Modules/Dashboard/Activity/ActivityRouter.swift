//
//  ActivityRouter.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 13/08/25.
//

import UIKit

protocol ActivityRouterProtocol: AnyObject {
    func presentRun(from: UIViewController)
    
}

final class ActivityRouter: ActivityRouterProtocol {
    
    func presentRun(from: UIViewController) {
        let runVC = RunRouter.makeModule()
        runVC.modalPresentationStyle = .fullScreen
        from.present(runVC, animated: true)
    }
    
}

extension ActivityRouter {
    static func makeModule() -> UIViewController {
        let interactor = ActivityInteractor()
        let router = ActivityRouter()
        let presenter = ActivityPresenter(interactor: interactor, router: router)
        let view = ActivityView()
        view.presenter = presenter
        presenter.attach(view: view)
        let nav = UINavigationController(rootViewController: view)
        nav.setNavigationBarHidden(true, animated: false)
        return nav
    }
}
