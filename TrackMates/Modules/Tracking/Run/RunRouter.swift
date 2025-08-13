//
//  RunRouter.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import UIKit

protocol RunRouterProtocol: AnyObject { }

final class RunRouter: RunRouterProtocol { }

extension RunRouter {
    static func makeModule() -> UIViewController {
        let interactor = RunInteractor()
        let presenter  = RunPresenter(interactor: interactor)
        let view       = RunView()
        view.presenter = presenter
        return view
    }
}
