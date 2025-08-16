//
//  ActivityRouter.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 13/08/25.
//

import UIKit

protocol ActivityRouterProtocol: AnyObject {
    func presentTracking(from: UIViewController, mode: TrackingMode)
    
}

final class ActivityRouter: ActivityRouterProtocol {
    
    func presentTracking(from: UIViewController, mode: TrackingMode) {
            let vc = TrackingRouter.makeModule(mode: mode)
            vc.modalPresentationStyle = .fullScreen
            from.present(vc, animated: true)
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
