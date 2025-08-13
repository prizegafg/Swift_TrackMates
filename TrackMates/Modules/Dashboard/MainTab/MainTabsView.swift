//
//  MainTabsView.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 13/08/25.
//

import UIKit

final class MainTabsView: UITabBarController, MainTabsViewProtocol, UITabBarControllerDelegate {
    private let presenter: MainTabsPresenterProtocol
    
    init(presenter: MainTabsPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setupAppearance()
        presenter.viewDidLoad()
    }

    func setTabs(_ vcs: [UIViewController]) {
        // seamless: set sekali, tanpa animasi
        setViewControllers(vcs, animated: false)
        selectedIndex = 0
    }

    private func setupAppearance() {
        let ap = UITabBarAppearance()
        ap.configureWithDefaultBackground()
        tabBar.standardAppearance = ap
        if #available(iOS 15.0, *) { tabBar.scrollEdgeAppearance = ap }
        
        tabBar.isTranslucent = false                
        tabBar.backgroundColor = .tmBackground
        tabBar.tintColor = .tmAccent
        tabBar.unselectedItemTintColor = .secondaryLabel
    }
}
