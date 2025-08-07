//
//  UserEntity.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import Foundation

struct UserEntity: Codable, Identifiable {
    let id: String      // userId (firebase uid)
    let username: String
    let firstName: String
    let lastName: String
    let email: String
    let dateOfBirth: Date

    init(id: String, username: String, firstName: String, lastName: String, email: String, dateOfBirth: Date) {
        self.id = id
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.dateOfBirth = dateOfBirth
    }
}
