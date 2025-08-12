//
//  HomeInteractor.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import Foundation

protocol HomeInteractorProtocol {
    func logout(completion: @escaping (Result<Void, Error>) -> Void)
}

final class HomeInteractor: HomeInteractorProtocol {
    private let auth: AuthServiceProtocol
    init(auth: AuthServiceProtocol = AuthService()) { self.auth = auth }

    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try auth.signOut() // Firebase signOut
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
}
