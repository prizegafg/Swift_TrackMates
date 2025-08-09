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
    private let userService: UserServiceProtocol
    private let userRepository: UserRepositoryProtocol

    init(userService: UserServiceProtocol = UserService(),
         userRepository: UserRepositoryProtocol = UserRepository()) {
        self.userService = userService
        self.userRepository = userRepository
    }

    func register(_ model: UserRegisterModel, completion: @escaping (Result<UserEntity, Error>) -> Void) {
        guard let password = model.password, !password.isEmpty else {
            completion(.failure(NSError(domain: "Register", code: -3,
                userInfo: [NSLocalizedDescriptionKey: "Password is required."])))
            return
        }

        Auth.auth().createUser(withEmail: model.email, password: password) { [weak self] authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let uid = authResult?.user.uid else {
                completion(.failure(NSError(domain: "Auth", code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "No user found."])))
                return
            }

            let entity = model.toEntity(id: uid)

            self?.userService.saveUser(user: entity) { serviceResult in
                switch serviceResult {
                case .success:
                    self?.userRepository.replaceLocal(entity) { repoResult in
                        switch repoResult {
                        case .success: completion(.success(entity))
                        case .failure(let repoError): completion(.failure(repoError))
                        }
                    }
                case .failure(let serviceError):
                    completion(.failure(serviceError))
                }
            }
        }
    }
}
