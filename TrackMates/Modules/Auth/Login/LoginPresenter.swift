//
//  LoginPresenter.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import Foundation
import Combine

import Foundation
import Combine

protocol LoginPresenterProtocol {
    var loginResultPublisher: AnyPublisher<UserEntity?, Never> { get }
    var errorPublisher: AnyPublisher<String?, Never> { get }
    func login(email: String, password: String)
}

final class LoginPresenter: LoginPresenterProtocol {
    private let interactor: LoginInteractorProtocol
    private let loginResultSubject = PassthroughSubject<UserEntity?, Never>()
    private let errorSubject = PassthroughSubject<String?, Never>()
    private var cancellables = Set<AnyCancellable>()

    var loginResultPublisher: AnyPublisher<UserEntity?, Never> { loginResultSubject.eraseToAnyPublisher() }
    var errorPublisher: AnyPublisher<String?, Never> { errorSubject.eraseToAnyPublisher() }

    init(interactor: LoginInteractorProtocol) {
        self.interactor = interactor
    }

    func login(email: String, password: String) {
        interactor.loginToFirebase(email: email, password: password) { [weak self] result in
            switch result {
            case .success(let userEntity):
                // Setelah dapat user dari Firebase, simpan ke CoreData
                self?.interactor.saveUserToLocal(userEntity) { saveResult in
                    switch saveResult {
                    case .success:
                        self?.loginResultSubject.send(userEntity)
                    case .failure(let saveError):
                        self?.errorSubject.send("Failed to save user: \(saveError.localizedDescription)")
                    }
                }
            case .failure(let error):
                self?.errorSubject.send(error.localizedDescription)
            }
        }
    }
}

