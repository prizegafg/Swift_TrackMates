//
//  TrackingRouter.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import UIKit

protocol TrackingRouterProtocol: AnyObject { }

final class TrackingRouter: TrackingRouterProtocol { }

extension TrackingRouter {
    static func makeModule(mode: TrackingMode) -> UIViewController {
        let interactor = TrackingInteractor()
        let presenter  = TrackingPresenter(interactor: interactor, mode: mode)
        let view       = TrackingView()
        view.presenter = presenter
        presenter.attach(view: view)
        return view
    }
}
