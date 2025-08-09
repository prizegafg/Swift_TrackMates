//
//  CaloryRepository.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import Foundation

protocol CaloryRepositoryProtocol {
    func getAll(completion: @escaping (Result<[CaloryEntity], Error>) -> Void)
}

// Placeholder entity (silakan pindah ke CaloryEntity.swift)
struct CaloryEntity: Codable, Identifiable { let id: String; let amount: Double; let date: Date }

final class CaloryRepository: CaloryRepositoryProtocol {
    func getAll(completion: @escaping (Result<[CaloryEntity], Error>) -> Void) {
        completion(.success([]))
    }
}
