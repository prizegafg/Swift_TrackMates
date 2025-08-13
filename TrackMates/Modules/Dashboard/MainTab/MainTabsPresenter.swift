//
//  MainTabsPresenter.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 13/08/25.
//

import UIKit

protocol MainTabsViewProtocol: AnyObject {
    func setTabs(_ vcs: [UIViewController])
}

protocol MainTabsPresenterProtocol: AnyObject {
    func attach(view: MainTabsViewProtocol)
    func viewDidLoad()
}

final class MainTabsPresenter: MainTabsPresenterProtocol {
    private weak var view: MainTabsViewProtocol?
    private let router: MainTabsRouterProtocol

    init(router: MainTabsRouterProtocol) { self.router = router }

    func attach(view: MainTabsViewProtocol) { self.view = view }

    func viewDidLoad() {
        let tabs = router.makeTabs()
        DispatchQueue.main.async { [weak self] in
            self?.view?.setTabs(tabs)
        }
    }
}
