//
//  UserService.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import Foundation
import FirebaseFirestore

protocol UserServiceProtocol {
    func fetchUser(userId: String, completion: @escaping (Result<UserEntity, Error>) -> Void)
    func saveUser(user: UserEntity, completion: @escaping (Result<Void, Error>) -> Void)
}

final class UserService: UserServiceProtocol {
    private let db = Firestore.firestore()
    
    func fetchUser(userId: String, completion: @escaping (Result<UserEntity, Error>) -> Void) {
        db.collection("users").document(userId).getDocument { snapshot, err in
            if let err = err {
                completion(.failure(err))
                return
            }
            guard let data = snapshot?.data(),
                  let username = data["username"] as? String,
                  let firstName = data["firstName"] as? String,
                  let lastName = data["lastName"] as? String,
                  let email = data["email"] as? String,
                  let dobString = data["dateOfBirth"] as? String,
                  let dob = ISO8601DateFormatter().date(from: dobString)
            else {
                completion(.failure(NSError(domain: "Firestore", code: -2, userInfo: [NSLocalizedDescriptionKey: "User data incomplete."])))
                return
            }
            let userEntity = UserEntity(id: userId, username: username, firstName: firstName, lastName: lastName, email: email, dateOfBirth: dob)
            completion(.success(userEntity))
        }
    }
    
    func saveUser(user: UserEntity, completion: @escaping (Result<Void, Error>) -> Void) {
           let userData: [String: Any] = [
               "username": user.username,
               "firstName": user.firstName,
               "lastName": user.lastName,
               "email": user.email,
               "dateOfBirth": ISO8601DateFormatter().string(from: user.dateOfBirth)
           ]
           db.collection("users").document(user.id).setData(userData) { error in
               if let error = error {
                   completion(.failure(error))
               } else {
                   completion(.success(()))
               }
           }
       }
}
