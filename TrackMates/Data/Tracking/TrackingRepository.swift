//
//  TrackingRepository.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import Foundation

import Foundation

protocol TrackingRepositoryProtocol {
    func getRuns(completion: @escaping (Result<[RunEntity], Error>) -> Void)
    func getRides(completion: @escaping (Result<[RideEntity], Error>) -> Void)
    func saveRun(_ run: RunEntity, completion: @escaping (Result<Void, Error>) -> Void)
}

struct RunEntity: Codable, Identifiable { let id: String; let distance: Double; let duration: TimeInterval; let date: Date; let calories: Double; let elevationGain: Double }
struct RideEntity: Codable, Identifiable { let id: String; let distance: Double; let duration: TimeInterval; let date: Date }

final class TrackingRepository: TrackingRepositoryProtocol {
    private let runsURL: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("runs.json")
    }()

    func getRuns(completion: @escaping (Result<[RunEntity], Error>) -> Void) {
        do {
            guard FileManager.default.fileExists(atPath: runsURL.path) else { completion(.success([])); return }
            let data = try Data(contentsOf: runsURL)
            let arr = try JSONDecoder().decode([RunEntity].self, from: data)
            completion(.success(arr))
        } catch { completion(.failure(error)) }
    }

    func getRides(completion: @escaping (Result<[RideEntity], Error>) -> Void) {
        completion(.success([]))
    }

    func saveRun(_ run: RunEntity, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            var arr: [RunEntity] = []
            if FileManager.default.fileExists(atPath: runsURL.path) {
                let data = try Data(contentsOf: runsURL)
                arr = (try? JSONDecoder().decode([RunEntity].self, from: data)) ?? []
            }
            arr.insert(run, at: 0)
            let data = try JSONEncoder().encode(arr)
            try data.write(to: runsURL, options: .atomic)
            completion(.success(()))
        } catch { completion(.failure(error)) }
    }
}

