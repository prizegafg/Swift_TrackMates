//
//  TrackingRepository.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import Foundation

protocol TrackingRepositoryProtocol {
    func getRuns(completion: @escaping (Result<[RunEntity], Error>) -> Void)
    func getRides(completion: @escaping (Result<[RideEntity], Error>) -> Void)
}

// Placeholder entity (silakan pindah ke file TrackingEntity.swift kalau sudah siap)
struct RunEntity: Codable, Identifiable { let id: String; let distance: Double; let duration: TimeInterval; let date: Date }
struct RideEntity: Codable, Identifiable { let id: String; let distance: Double; let duration: TimeInterval; let date: Date }

final class TrackingRepository: TrackingRepositoryProtocol {
    func getRuns(completion: @escaping (Result<[RunEntity], Error>) -> Void) {
        // TODO: ambil dari Core Data/Realm nantinya.
        completion(.success([]))
    }
    func getRides(completion: @escaping (Result<[RideEntity], Error>) -> Void) {
        completion(.success([]))
    }
}
