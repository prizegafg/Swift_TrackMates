//
//  TrackingService.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

protocol TrackingServiceProtocol {
    func saveTracking(userId: String, payload: [String: Any], completion: @escaping (Result<Void, Error>) -> Void)
}

final class TrackingService: TrackingServiceProtocol {
    private let db = Firestore.firestore()
    func saveTracking(userId: String, payload: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        let id = UUID().uuidString
        db.collection("users").document(userId)
            .collection("runs").document(id)
            .setData(payload) { err in
                if let err = err { completion(.failure(err)) } else { completion(.success(())) }
            }
    }
}

extension Array where Element == CLLocationCoordinate2D {
    func toGeoPoints() -> [[String: Double]] {
        map { ["lat": $0.latitude, "lng": $0.longitude] }
    }
}


