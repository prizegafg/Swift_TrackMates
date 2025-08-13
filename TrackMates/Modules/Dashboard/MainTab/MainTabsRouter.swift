//
//  MainTabsRouter.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 13/08/25.
//

import UIKit

protocol MainTabsRouterProtocol: AnyObject {
    func makeTabs() -> [UIViewController]
}

final class MainTabsRouter: MainTabsRouterProtocol {
    func makeTabs() -> [UIViewController] {
        // HOME
        let home = HomeRouter.makeModule()
        home.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        // ACTIVITY
        let activity = ActivityRouter.makeModule()
        activity.tabBarItem = UITabBarItem(
            title: "Activity",
            image: UIImage(systemName: "figure.run"),
            selectedImage: UIImage(systemName: "figure.run")
        )

        // CHALLENGE
        let challenge = ChallengeRouter.makeModule()
        challenge.tabBarItem = UITabBarItem(
            title: "Challenge",
            image: UIImage(systemName: "trophy"),
            selectedImage: UIImage(systemName: "trophy.fill")
        )

        // MORE
        let settings = SettingsRouter.makeModule()
        settings.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gearshape"),
            selectedImage: UIImage(systemName: "gearshape.fill")
        )

        return [home, activity, challenge, settings]

    }
}

extension MainTabsRouter {
    static func makeModule() -> UIViewController {
        let router = MainTabsRouter()
        let presenter = MainTabsPresenter(router: router)
        let view = MainTabsView(presenter: presenter)   // <-- inject via init
        presenter.attach(view: view)
        return view
    }
}
