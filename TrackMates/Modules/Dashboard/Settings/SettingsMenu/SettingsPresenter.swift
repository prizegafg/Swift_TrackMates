//
//  SettingsPresenter.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 13/08/25.
//

import UIKit

protocol SettingsViewProtocol: AnyObject { func setTitle(_ t: String) }
protocol SettingsPresenterProtocol: AnyObject {
    func attach(view: SettingsViewProtocol)
    func viewDidLoad()
}

final class SettingsPresenter: SettingsPresenterProtocol {
    private weak var view: SettingsViewProtocol?
    private let interactor: SettingsInteractorProtocol
    private let router: SettingsRouterProtocol

    init(interactor: SettingsInteractorProtocol, router: SettingsRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    func attach(view: SettingsViewProtocol) { self.view = view }
    func viewDidLoad() { view?.setTitle("Settings") } // business logic di presenter
}
