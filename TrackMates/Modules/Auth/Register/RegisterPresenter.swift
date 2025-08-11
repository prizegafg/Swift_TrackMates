//
//  RegisterPresenter.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import Foundation
import Combine
import UIKit

protocol RegisterViewProtocol: AnyObject {
    var vc: UIViewController { get }
    func showAlert(title: String, message: String, onOK: @escaping () -> Void)
    func setLoading(_ loading: Bool)
}

protocol RegisterPresenterProtocol {
    var registerResultPublisher: AnyPublisher<UserEntity?, Never> { get }
    var errorPublisher: AnyPublisher<String?, Never> { get }

    func attach(view: RegisterViewProtocol)
    func onTapRegister(username: String, email: String, dob: Date, password: String, repeatPassword: String)
    func onTapLoginLink()
}

final class RegisterPresenter: RegisterPresenterProtocol {
    private weak var view: RegisterViewProtocol?
    private let interactor: RegisterInteractorProtocol
    private let router: RegisterRouterProtocol

    private let registerResultSubject = PassthroughSubject<UserEntity?, Never>()
    private let errorSubject = PassthroughSubject<String?, Never>()
    var registerResultPublisher: AnyPublisher<UserEntity?, Never> { registerResultSubject.eraseToAnyPublisher() }
    var errorPublisher: AnyPublisher<String?, Never> { errorSubject.eraseToAnyPublisher() }

    init(interactor: RegisterInteractorProtocol, router: RegisterRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    func attach(view: RegisterViewProtocol) { self.view = view }

    func onTapRegister(username: String, email: String, dob: Date, password: String, repeatPassword: String) {
        // 🔐 Semua validasi di Presenter
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorSubject.send("Email is required.")
            return
        }
        guard !password.isEmpty else {
            errorSubject.send("Password is required.")
            return
        }
        guard password == repeatPassword else {
            errorSubject.send("Passwords do not match.")
            return
        }

        let model = UserRegisterModel(
            username: username.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            firstName: "",
            lastName: "",
            dob: dob,
            password: password
        )

        view?.setLoading(true)
        interactor.register(model) { [weak self] result in
            guard let self else { return }
            self.view?.setLoading(false)
            switch result {
            case .success(let user):
                self.registerResultSubject.send(user)
                self.view?.showAlert(title: "Registration Successful",
                                     message: "Please sign in to continue.") { [weak self] in
                    guard let self, let vc = self.view?.vc else { return }
                    self.router.navigateToLogin(from: vc)
                }
            case .failure(let error):
                self.errorSubject.send(error.localizedDescription)
            }
        }
    }

    func onTapLoginLink() {
        guard let vc = view?.vc else { return }
        router.navigateToLogin(from: vc)
    }
}

