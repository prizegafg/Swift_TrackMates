//
//  ChallengePresenter.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 13/08/25.
//

import UIKit

protocol ChallengeViewProtocol: AnyObject { func setTitle(_ t: String) }
protocol ChallengePresenterProtocol: AnyObject {
    func attach(view: ChallengeViewProtocol)
    func viewDidLoad()
}

final class ChallengePresenter: ChallengePresenterProtocol {
    private weak var view: ChallengeViewProtocol?
    private let interactor: ChallengeInteractorProtocol
    private let router: ChallengeRouterProtocol

    init(interactor: ChallengeInteractorProtocol, router: ChallengeRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    func attach(view: ChallengeViewProtocol) { self.view = view }
    func viewDidLoad() { view?.setTitle("Challenge") }
}
