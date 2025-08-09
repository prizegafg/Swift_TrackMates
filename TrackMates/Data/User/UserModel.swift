//
//  UserModel.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import Foundation

struct UserRegisterModel {
    let username: String
    let email: String
    let firstName: String
    let lastName: String
    let dob: Date
    let password: String?     
}

extension UserRegisterModel {
    func toEntity(id: String) -> UserEntity {
        UserEntity(
            id: id,
            username: username.isEmpty ? (email.split(separator: "@").first.map(String.init) ?? email) : username,
            firstName: firstName,
            lastName: lastName,
            email: email,
            dateOfBirth: dob
        )
    }
}
