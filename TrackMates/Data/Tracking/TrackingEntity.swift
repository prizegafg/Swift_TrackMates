//
//  TrackingEntity.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import Foundation

struct TrackingEntity: Codable, Identifiable {
    let id: String
    let distance: Double
    let duration: TimeInterval
    let date: Date
    let calories: Double
    let elevationGain: Double
}
