//
//  OnboardingView.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 10/08/25.
//

import UIKit

final class OnboardingView: UIViewController {
    var onFinish: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        // Placeholder UI
        let btn = UIButton(type: .system)
        btn.setTitle("Get Started", for: .normal)
        btn.addTarget(self, action: #selector(done), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(btn)
        NSLayoutConstraint.activate([
            btn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            btn.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    @objc private func done() { onFinish?() }
}
