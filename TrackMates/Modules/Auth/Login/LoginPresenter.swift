//
//  LoginPresenter.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//


import Foundation
import Combine
import FirebaseAuth
import UIKit

protocol LoginViewProtocol: AnyObject {
    var vc: UIViewController { get }
    func setLoading(_ loading: Bool)
    func showAlert(title: String, message: String)
}

protocol LoginPresenterProtocol {
    var loginResultPublisher: AnyPublisher<UserEntity?, Never> { get }
    var errorPublisher: AnyPublisher<String?, Never> { get }

    func attach(view: LoginViewProtocol)
    func onTapLogin(email: String, password: String)
    func onTapRegister()
}

final class LoginPresenter: LoginPresenterProtocol {
    private weak var view: LoginViewProtocol?
    private let interactor: LoginInteractorProtocol
    private let router: LoginRouterProtocol

    private let loginResultSubject = PassthroughSubject<UserEntity?, Never>()
    private let errorSubject = PassthroughSubject<String?, Never>()
    var loginResultPublisher: AnyPublisher<UserEntity?, Never> { loginResultSubject.eraseToAnyPublisher() }
    var errorPublisher: AnyPublisher<String?, Never> { errorSubject.eraseToAnyPublisher() }

    init(interactor: LoginInteractorProtocol, router: LoginRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    func attach(view: LoginViewProtocol) { self.view = view }

    func onTapLogin(email: String, password: String) {
        let e = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !e.isEmpty else {
            let msg = "Email is required."
            errorSubject.send(msg); view?.showAlert(title: "Login Failed", message: msg)
            return
        }
        guard !password.isEmpty else {
            let msg = "Password is required."
            errorSubject.send(msg); view?.showAlert(title: "Login Failed", message: msg)
            return
        }

        view?.setLoading(true)
        interactor.login(email: e, password: password) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                self.view?.setLoading(false)
                switch result {
                case .success(let user):
                    self.loginResultSubject.send(user)
                    if let vc = self.view?.vc {
                        self.router.navigateToHome(from: vc, user: user)
                    }
                case .failure(let err):
                    let message = self.errorMsg(err)                
                    self.errorSubject.send(message)
                    self.view?.showAlert(title: "Login Failed", message: message)
                }
            }
        }
    }
    
    private func errorMsg(_ err: Error) -> String {
        guard let e = err as NSError? else { return err.localizedDescription }
        switch e.code {
        case 17008: return "Email address is invalid."
        case 17009: return "Incorrect password."
        case 17011: return "No account found for this email."
        default:    return e.localizedDescription
        }
    }

    func onTapRegister() {
        guard let vc = view?.vc else { return }
        router.navigateToRegister(from: vc)
    }
}

