//
//  LoginInteractor.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import Foundation

protocol LoginInteractorProtocol {
    func login(email: String, password: String, completion: @escaping (Result<UserEntity, Error>) -> Void)
}

final class LoginInteractor: LoginInteractorProtocol {
    private let authService: AuthServiceProtocol
    private let userService: UserServiceProtocol
    private let userRepository: UserRepositoryProtocol

    init(authService: AuthServiceProtocol = AuthService(),
         userService: UserServiceProtocol = UserService(),
         userRepository: UserRepositoryProtocol = UserRepository()) {
        self.authService = authService
        self.userService = userService
        self.userRepository = userRepository
    }

    func login(email: String, password: String, completion: @escaping (Result<UserEntity, Error>) -> Void) {
        authService.signIn(email: email, password: password) { [weak self] signInResult in
            guard let self = self else { return }
            switch signInResult {
            case .failure(let err):
                completion(.failure(err))
            case .success(let uid):
                self.userService.fetchUser(userId: uid) { fetchResult in
                    switch fetchResult {
                    case .failure(let err):
                        completion(.failure(err))
                    case .success(let entity):
                        self.userRepository.replaceLocal(entity) { saveResult in
                            switch saveResult {
                            case .success:
                                completion(.success(entity))
                            case .failure(let err):
                                completion(.failure(err))
                            }
                        }
                    }
                }
            }
        }
    }
}

