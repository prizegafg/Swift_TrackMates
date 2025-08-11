//
//  RegisterInteractor.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import Foundation
import FirebaseAuth

protocol RegisterInteractorProtocol {
    func register(_ model: UserRegisterModel, completion: @escaping (Result<UserEntity, Error>) -> Void)
}

final class RegisterInteractor: RegisterInteractorProtocol {
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
    
    func register(_ model: UserRegisterModel, completion: @escaping (Result<UserEntity, Error>) -> Void) {
        guard let password = model.password, !password.isEmpty else {
            completion(.failure(NSError(domain: "Register", code: -3,
                                        userInfo: [NSLocalizedDescriptionKey: "Password is required."])))
            return
        }
        
        authService.signUp(email: model.email, password: password) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let err):
                completion(.failure(err))
            case .success(let uid):
                let entity = model.toEntity(id: uid)
                self.userService.saveUser(user: entity) { serviceResult in
                    switch serviceResult {
                    case .success:
                        self.userRepository.replaceLocal(entity) { repoResult in
                            switch repoResult {
                            case .success: completion(.success(entity))
                            case .failure(let repoErr): completion(.failure(repoErr))
                            }
                        }
                    case .failure(let serviceErr):
                        completion(.failure(serviceErr))
                    }
                }
            }
        }
    }
}
