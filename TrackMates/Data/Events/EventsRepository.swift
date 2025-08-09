//
//  EventsRepository.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 10/08/25.
//

import Foundation

protocol EventsRepositoryProtocol {
    func getPastEvents(completion: @escaping (Result<[EventEntity], Error>) -> Void)
    func getSharedMedia(completion: @escaping (Result<[SharedMediaEntity], Error>) -> Void)
}


struct EventEntity: Codable, Identifiable { let id: String; let title: String; let date: Date }
struct SharedMediaEntity: Codable, Identifiable { let id: String; let url: String; let ownerId: String; let date: Date }

final class EventsRepository: EventsRepositoryProtocol {
    func getPastEvents(completion: @escaping (Result<[EventEntity], Error>) -> Void) {
        completion(.success([]))
    }
    func getSharedMedia(completion: @escaping (Result<[SharedMediaEntity], Error>) -> Void) {
        completion(.success([]))
    }
}
