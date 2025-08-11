//
//  OnboardingRouter.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 10/08/25.
//

import UIKit

protocol OnboardingRouterProtocol: AnyObject {
    func finish()
}

final class OnboardingRouter: OnboardingRouterProtocol {
    private let didFinish: () -> Void
    init(didFinish: @escaping () -> Void) { self.didFinish = didFinish }
    func finish() { didFinish() }
}

extension OnboardingRouter {
    static func makeModule(didFinish: @escaping () -> Void) -> UIViewController {
        let router = OnboardingRouter(didFinish: didFinish)
        let presenter = OnboardingPresenter(router: router)
        let view = OnboardingView()
        view.presenter = presenter
        presenter.attach(view: view)
        return view
    }
}
