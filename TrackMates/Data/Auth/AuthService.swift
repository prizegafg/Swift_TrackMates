//
//  AuthService.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 10/08/25.
//

import Foundation
import FirebaseAuth

protocol AuthServiceProtocol {
    func signIn(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void)
    func signOut() throws
    func currentUserId() -> String?
}

final class AuthService: AuthServiceProtocol {
    func signIn(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error { completion(.failure(error)); return }
            guard let uid = result?.user.uid else {
                completion(.failure(NSError(domain: "Auth", code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "No user found."])))
                return
            }
            completion(.success(uid))
        }
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func currentUserId() -> String? {
        Auth.auth().currentUser?.uid
    }
}
