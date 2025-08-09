//
//  RegisterPresenter.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import Foundation
import Combine

protocol RegisterPresenterProtocol {
    var registerResultPublisher: AnyPublisher<UserEntity?, Never> { get }
        var errorPublisher: AnyPublisher<String?, Never> { get }
        func register(_ model: UserRegisterModel)
}

final class RegisterPresenter: RegisterPresenterProtocol {
    private let interactor: RegisterInteractorProtocol
    private let registerResultSubject = PassthroughSubject<UserEntity?, Never>()
    private let errorSubject = PassthroughSubject<String?, Never>()
    private var cancellables = Set<AnyCancellable>()

    var registerResultPublisher: AnyPublisher<UserEntity?, Never> { registerResultSubject.eraseToAnyPublisher() }
    var errorPublisher: AnyPublisher<String?, Never> { errorSubject.eraseToAnyPublisher() }
    
    init(interactor: RegisterInteractorProtocol) {
        self.interactor = interactor
    }
    
    func register(_ model: UserRegisterModel) {
        guard let pwd = model.password, !pwd.isEmpty else {
            errorSubject.send("Password is required.")
            return
        }
        interactor.register(model) { [weak self] result in
            switch result {
            case .success(let userEntity):
                self?.registerResultSubject.send(userEntity)
            case .failure(let error):
                self?.errorSubject.send(error.localizedDescription)
            }
        }
    }
}
