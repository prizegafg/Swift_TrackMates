//
//  HealthKitService.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 13/08/25.
//

import HealthKit

final class HealthKitService {
    private let store = HKHealthStore()
    func requestAuth(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else { completion(false); return }
        let read: Set = [HKObjectType.quantityType(forIdentifier: .heartRate)!,
                         HKObjectType.workoutType()]
        let write: Set = [HKObjectType.workoutType()]
        store.requestAuthorization(toShare: write, read: read) { ok, _ in completion(ok) }
    }
}
