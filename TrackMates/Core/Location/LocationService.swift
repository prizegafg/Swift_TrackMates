//
//  LocationService.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 13/08/25.
//

import Foundation
import CoreLocation

protocol LocationServiceProtocol: AnyObject {
    var onAuthChange: ((CLAuthorizationStatus) -> Void)? { get set }
    var onLocation: ((CLLocation) -> Void)? { get set }
    func requestAuth()
    func start()
    func pause()
    func stop()
    var isRunning: Bool { get }
}

final class LocationService: NSObject, CLLocationManagerDelegate, LocationServiceProtocol {
    private let mgr = CLLocationManager()
    private(set) var isRunning = false
    var onAuthChange: ((CLAuthorizationStatus) -> Void)?
    var onLocation: ((CLLocation) -> Void)?

    override init() {
        super.init()
        mgr.delegate = self
        mgr.desiredAccuracy = kCLLocationAccuracyBest
        mgr.activityType = .fitness
        mgr.distanceFilter = 5 // meter
        mgr.pausesLocationUpdatesAutomatically = true
        if #available(iOS 11.0, *) { mgr.showsBackgroundLocationIndicator = true }
    }

    func requestAuth() {
        switch mgr.authorizationStatus {
        case .notDetermined: mgr.requestWhenInUseAuthorization()
        default: onAuthChange?(mgr.authorizationStatus)
        }
    }
    func start() {
        guard !isRunning else { return }
        isRunning = true
        mgr.allowsBackgroundLocationUpdates = true
        mgr.startUpdatingLocation()
        
    }
    
    func pause() {
        guard isRunning else { return }
        mgr.stopUpdatingLocation()
        isRunning = false
    }
    
    func stop()  {
        isRunning = false
        mgr.stopUpdatingLocation()
        mgr.allowsBackgroundLocationUpdates = false
    }

    // MARK: CLLocationManagerDelegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        onAuthChange?(manager.authorizationStatus)
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            // ok
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for loc in locations where loc.horizontalAccuracy >= 0 {
            onLocation?(loc)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) { print("Loc err:", error) }
}
