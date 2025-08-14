//
//  TrackingRepository.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import Foundation

protocol TrackingRepositoryProtocol {
    func getTracking(completion: @escaping (Result<[TrackingEntity], Error>) -> Void)
    func saveTracking(_ run: TrackingEntity, completion: @escaping (Result<Void, Error>) -> Void)
}

final class TrackingRepository: TrackingRepositoryProtocol {
    private let trackingsURL: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("runs.json")
    }()

    func getTracking(completion: @escaping (Result<[TrackingEntity], Error>) -> Void) {
        do {
            guard FileManager.default.fileExists(atPath: trackingsURL.path) else { completion(.success([])); return }
            let data = try Data(contentsOf: trackingsURL)
            let arr = try JSONDecoder().decode([TrackingEntity].self, from: data)
            completion(.success(arr))
        } catch { completion(.failure(error)) }
    }


    func saveTracking(_ run: TrackingEntity, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            var arr: [TrackingEntity] = []
            if FileManager.default.fileExists(atPath: trackingsURL.path) {
                let data = try Data(contentsOf: trackingsURL)
                arr = (try? JSONDecoder().decode([TrackingEntity].self, from: data)) ?? []
            }
            arr.insert(run, at: 0)
            let data = try JSONEncoder().encode(arr)
            try data.write(to: trackingsURL, options: .atomic)
            completion(.success(()))
        } catch { completion(.failure(error)) }
    }
}

