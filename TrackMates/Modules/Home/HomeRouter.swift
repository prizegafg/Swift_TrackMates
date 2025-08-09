//
//  HomeRouter.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import UIKit

protocol HomeRouterProtocol {}

final class HomeRouter: HomeRouterProtocol {}

extension HomeRouter {
    static func makeModule() -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        vc.title = "Home"
        let nav = UINavigationController(rootViewController: vc)
        return nav
    }
}
