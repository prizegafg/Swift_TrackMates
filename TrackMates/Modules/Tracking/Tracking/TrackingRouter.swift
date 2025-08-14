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
    static func makeModule() -> UIViewController {
        let interactor = TrackingInteractor()
        let presenter  = TrackingPresenter(interactor: interactor)
        let view       = TrackingView()
        view.presenter = presenter
        return view
    }
}
