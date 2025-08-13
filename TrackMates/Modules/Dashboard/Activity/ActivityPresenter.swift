//
//  ActivityPresenter.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 13/08/25.
//

import UIKit

protocol ActivityViewProtocol: AnyObject { func setTitle(_ t: String) }
protocol ActivityPresenterProtocol: AnyObject {
    func attach(view: ActivityViewProtocol)
    func viewDidLoad()
}

final class ActivityPresenter: ActivityPresenterProtocol {
    private weak var view: ActivityViewProtocol?
    private let interactor: ActivityInteractorProtocol
    private let router: ActivityRouterProtocol

    init(interactor: ActivityInteractorProtocol, router: ActivityRouterProtocol) {
        self.interactor = interactor; self.router = router
    }

    func attach(view: ActivityViewProtocol) { self.view = view }
    func viewDidLoad() { view?.setTitle("Activity") }
}
