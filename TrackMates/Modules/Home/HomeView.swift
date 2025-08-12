//
//  HomeView.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import UIKit

final class HomeView: UIViewController, HomeViewProtocol {
    var presenter: HomePresenterProtocol!

    var vc: UIViewController { self }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Home"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Logout",
            style: .plain,
            target: self,
            action: #selector(tapLogout)
        )
    }

    @objc private func tapLogout() {
        presenter.onTapLogout()
    }

    func showError(_ message: String) {
        let alert = UIAlertController(title: "Logout Failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
