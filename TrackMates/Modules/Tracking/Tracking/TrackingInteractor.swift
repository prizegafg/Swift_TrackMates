//
//  TrackingInteractor.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import Foundation
import CoreLocation
import FirebaseAuth
import FirebaseCore

enum TrackingMode {
    case run, walk, bike
}

protocol TrackingInteractorProtocol: AnyObject {
    var onLocation: ((CLLocation) -> Void)? { get set }
    var onHeartRate: ((Int) -> Void)? { get set } 
    func askPermission(_ done: @escaping (Bool) -> Void)
    func start()
    func pause()
    func resume()
    func stop()
    func saveTracking(distance: Double, duration: TimeInterval, calories: Double, elevationGain: Double, completion: @escaping (Result<Void, Error>) -> Void)
    func estimateCalories(distance: Double, duration: TimeInterval) -> Double
}

final class TrackingInteractor: TrackingInteractorProtocol {
    private let loc: LocationServiceProtocol
    private let repo: TrackingRepositoryProtocol
    private let service: TrackingServiceProtocol
    private let auth: AuthServiceProtocol
    
    var onLocation: ((CLLocation) -> Void)?
    var onHeartRate: ((Int) -> Void)?
    
    init(loc: LocationServiceProtocol = LocationService(),
         repo: TrackingRepositoryProtocol = TrackingRepository(),
         service: TrackingServiceProtocol = TrackingService(),
         auth: AuthServiceProtocol = AuthService()) {
        self.loc = loc; self.repo = repo; self.service = service; self.auth = auth
        self.loc.onLocation = { [weak self] l in self?.onLocation?(l) }
    }
    
    func askPermission(_ done: @escaping (Bool) -> Void) {
        var fired = false
        loc.onAuthChange = { st in
            guard !fired else { return }
            switch st {
            case .authorizedWhenInUse, .authorizedAlways: fired = true; done(true)
            case .denied, .restricted:                   fired = true; done(false)
            case .notDetermined: break
            @unknown default:                            fired = true; done(false)
            }
        }
        loc.requestAuth()
    }
    func start()   { loc.start() }
    func pause()   { loc.pause() }
    func resume()  { loc.start() }
    func stop()    { loc.stop() }
    
    func saveTracking(distance: Double, duration: TimeInterval, calories: Double, elevationGain: Double, completion: @escaping (Result<Void, Error>) -> Void) {
        let entity = TrackingEntity(id: UUID().uuidString,
                               distance: distance,
                               duration: duration,
                               date: Date(),
                               calories: calories,
                               elevationGain: elevationGain)
        repo.saveTracking(entity) { [weak self] localRes in
            switch localRes {
            case .failure(let e): completion(.failure(e))
            case .success:
                guard let uid = self?.auth.currentUserId() else { completion(.success(())); return }
                let payload: [String: Any] = [
                    "id": entity.id,
                    "distance": entity.distance,
                    "duration": entity.duration,
                    "date": Timestamp(date: entity.date),
                    "calories": entity.calories,
                    "elevationGain": entity.elevationGain
                ]
                self?.service.saveTracking(userId: uid, payload: payload) { _ in
                    completion(.success(()))
                }
            }
        }
    }
    
    // Sederhana: gunakan MET by speed (rough)
    func estimateCalories(distance: Double, duration: TimeInterval) -> Double {
        guard duration > 0 else { return 0 }
        let speedKmh = (distance/1000) / (duration/3600)
        let met: Double = {
            switch speedKmh {
            case ..<6.0: return 6.0
            case ..<8.0: return 8.3
            case ..<10:  return 9.8
            case ..<12:  return 11.0
            case ..<14:  return 12.5
            case ..<16:  return 14.0
            default:     return 16.0
            }
        }()
        let weightKg: Double = 70
        let minutes = duration/60
        return met * 3.5 * weightKg / 200.0 * minutes
    }
}
