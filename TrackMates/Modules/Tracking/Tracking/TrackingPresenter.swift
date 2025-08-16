//
//  TrackingPresenter.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import UIKit
import CoreLocation

struct TrackingVM {
    let distanceText: String
    let paceText: String
    let caloriesText: String
    let elevText: String
    let bpmText: String
    let timeText: String
    let isPaused: Bool
}
protocol TrackingViewProtocol: AnyObject {
    var vc: UIViewController { get }
    func render(_ vm: TrackingVM)
    func showPermissionHint()
    func closeAfterSaved()
    func showError(_ msg: String)
    func showTitle(_ text: String)
}
protocol TrackingPresenterProtocol: AnyObject {
    func attach(view: TrackingViewProtocol)
    func viewDidLoad()
    func tapPauseResume()
    func tapStop()
}

final class TrackingPresenter: TrackingPresenterProtocol {
    private weak var view: TrackingViewProtocol?
    private let interactor: TrackingInteractorProtocol
    private let mode: TrackingMode
    
    private var startAt: Date?
    private var timer: Timer?
    private var elapsed: TimeInterval = 0
    private var distance: Double = 0 // meters
    private var elevGain: Double = 0
    private var lastLoc: CLLocation?
    private var isPaused = true
    private var started = false
    private var calories: Double = 0
    private var bpm: Int? = nil
    
    init(interactor: TrackingInteractorProtocol, mode: TrackingMode) {
        self.interactor = interactor
        self.mode = mode
        
    }
    
    func attach(view: TrackingViewProtocol) { self.view = view }
    
    func viewDidLoad() {
        interactor.askPermission { [weak self] granted in
            guard let self else { return }
            if granted { self.view?.showPermissionHint() }
            self.render()
        }
        
        let title: String
        switch mode {
        case .run:  title = "RUNNING"
        case .walk: title = "WALKING"
        case .bike: title = "CYCLING"
        }
        view?.showTitle(title)
        
        interactor.onLocation = { [weak self] loc in self?.handle(loc) }
        interactor.onHeartRate = { [weak self] hr in self?.bpm = hr }
    }
    
    private func start() {
        guard !started else { return }
        started = true
        isPaused = false
        startAt = Date()
        elapsed = 0; distance = 0; elevGain = 0; lastLoc = nil; calories = 0; bpm = nil
        interactor.start()
        runTimer()
        render()
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func tapPauseResume() {
        guard started else {
            start()
            return
        }
        isPaused.toggle()
        if isPaused { interactor.pause(); stopTimer() }
        else        { interactor.resume(); runTimer() }
        render()
    }
    
    func tapStop() {
        started = false
        timer?.invalidate()
        interactor.stop()
        interactor.saveTracking(distance: distance, duration: elapsed, calories: calories, elevationGain: elevGain) { [weak self] result in
            switch result {
            case .success: self?.view?.closeAfterSaved()
            case .failure(let err): self?.view?.showError(err.localizedDescription)
            }
        }
    }
    
    private func runTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.elapsed += 1
            self.calories = self.interactor.estimateCalories(distance: self.distance, duration: self.elapsed)
            self.render()
        }
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func handle(_ loc: CLLocation) {
        guard !isPaused else { return }
        defer { lastLoc = loc }
        if let prev = lastLoc {
            let d = loc.distance(from: prev)
            if d >= 0 { distance += d }
            let gain = max(loc.altitude - prev.altitude, 0)
            if gain > 0 { elevGain += gain }
        }
        render()
    }
    
    private func render() {
        let ctaTitle: String = !started ? "Start" : (isPaused ? "Resume" : "Pause")
        let pace: String = {
            guard distance > 0, elapsed > 0 else { return "--'--\"" }
            let secPerKm = elapsed / max(distance/1000, 0.0001)
            return Self.formatPace(secPerKm)
        }()
        let vm = TrackingVM(
            distanceText: String(format: "%.2f", distance/1000) + " KM",
            paceText: pace,
            caloriesText: String(format: "%.0f Kcal", calories),
            elevText: String(format: "%.0f m", elevGain),
            bpmText: bpm.map { "\($0) Bpm" } ?? "— Bpm",
            timeText: Self.formatTime(elapsed),
            isPaused: isPaused
        )
        view?.render(vm)
    }
    
    private static func formatTime(_ t: TimeInterval) -> String {
        let s = Int(t)
        let h = s/3600, m = (s%3600)/60, sec = s%60
        return (h > 0) ? String(format: "%02d:%02d:%02d", h, m, sec)
        : String(format: "%02d:%02d:%02d", 0, m, sec)
    }
    private static func formatPace(_ secPerKm: Double) -> String {
        let m = Int(secPerKm) / 60
        let s = Int(secPerKm) % 60
        return String(format: "%d'%02d\"", m, s)
    }
}
