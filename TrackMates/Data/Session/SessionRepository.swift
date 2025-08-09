//
//  SessionRepository.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import Foundation

protocol SessionRepositoryProtocol {
    func hasSeenOnboarding() -> Bool
    func setHasSeenOnboarding(_ seen: Bool)
}

final class SessionRepository: SessionRepositoryProtocol {
    private let kSeen = "tm_seen_onboarding"
    func hasSeenOnboarding() -> Bool {
        UserDefaults.standard.bool(forKey: kSeen)
    }
    func setHasSeenOnboarding(_ seen: Bool) {
        UserDefaults.standard.set(seen, forKey: kSeen)
    }
}
