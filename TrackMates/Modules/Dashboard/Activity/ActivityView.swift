//
//  ActivityView.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 13/08/25.
//

import UIKit

final class ActivityView: UIViewController, ActivityViewProtocol {
    var presenter: ActivityPresenterProtocol!

    private let titleLbl: UILabel = {
        let l = UILabel()
        l.text = "Activity"; l.font = .systemFont(ofSize: 28, weight: .bold)
        l.textColor = .tmLabelPrimary; l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .tmBackground
        view.addSubview(titleLbl)
        NSLayoutConstraint.activate([
            titleLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLbl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
        ])
        presenter.viewDidLoad()
    }

    func setTitle(_ t: String) { titleLbl.text = t }
}
