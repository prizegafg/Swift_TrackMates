//
//  SessionService.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import Foundation
import FirebaseAuth

protocol SessionServiceProtocol {
    func isAuthenticated() -> Bool
    func currentUserId() -> String?
}

final class SessionService: SessionServiceProtocol {
    func isAuthenticated() -> Bool { Auth.auth().currentUser != nil }
    func currentUserId() -> String? { Auth.auth().currentUser?.uid }
}
