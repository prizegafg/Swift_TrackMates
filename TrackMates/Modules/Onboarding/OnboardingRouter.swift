//
//  OnboardingRouter.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 10/08/25.
//

import UIKit

protocol OnboardingRouterProtocol {}

final class OnboardingRouter: OnboardingRouterProtocol {}

extension OnboardingRouter {
    static func makeModule(didFinish: @escaping () -> Void) -> UIViewController {
        let vc = OnboardingView()
        vc.onFinish = didFinish
        return vc
    }
}
