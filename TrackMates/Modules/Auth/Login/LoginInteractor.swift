//
//  LoginInteractor.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import Foundation
import FirebaseAuth

protocol LoginInteractorProtocol {
    func login(email: String, password: String, completion: @escaping (Result<UserEntity, Error>) -> Void)
}

final class LoginInteractor: LoginInteractorProtocol {
    private let userService: UserServiceProtocol
    private let userRepository: UserRepositoryProtocol

    init(userService: UserServiceProtocol = UserService(), userRepository: UserRepositoryProtocol = UserRepository()) {
        self.userService = userService
        self.userRepository = userRepository
    }

    func login(email: String, password: String, completion: @escaping (Result<UserEntity, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let user = authResult?.user else {
                completion(.failure(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user found."])))
                return
            }
            let uid = user.uid
            self.userService.fetchUser(userId: uid) { [weak self] fetchResult in
                switch fetchResult {
                case .success(let userEntity):
                    self?.userRepository.replaceLocal(userEntity) { repoResult in
                        switch repoResult {
                        case .success:
                            completion(.success(userEntity))
                        case .failure(let repoError):
                            completion(.failure(repoError))
                        }
                    }
                case .failure(let fetchError):
                    completion(.failure(fetchError))
                }
            }
        }
    }
}
