//
//  HomeInteractor.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import Foundation

protocol HomeInteractorProtocol {
    func logout(completion: @escaping (Result<Void, Error>) -> Void)
    func loadHeader(completion: @escaping (Result<HomeHeaderVM, Error>) -> Void)
    func loadWeeklyStats(completion: @escaping (Result<HomeStatsVM, Error>) -> Void)
}

final class HomeInteractor: HomeInteractorProtocol {
    private let auth: AuthServiceProtocol
    private let userRepo: UserRepositoryProtocol
    private let trackingRepo: TrackingRepositoryProtocol

    init(auth: AuthServiceProtocol = AuthService(),
         userRepo: UserRepositoryProtocol = UserRepository(),
         trackingRepo: TrackingRepositoryProtocol = TrackingRepository()) {
        self.auth = auth
        self.userRepo = userRepo
        self.trackingRepo = trackingRepo
    }

    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try auth.signOut()
            userRepo.wipeAll { _ in
                completion(.success(()))
            }
        } catch {
            completion(.failure(error))
        }
    }

    func loadHeader(completion: @escaping (Result<HomeHeaderVM, Error>) -> Void) {
        userRepo.current { result in
            let name: String = (try? result.get()?.firstName).flatMap { ($0?.isEmpty == false) ? $0! : nil }
                ?? (try? result.get()?.username) ?? "Runner"
            let hour = Calendar.current.component(.hour, from: Date())
            let g: String = (hour < 12) ? "Good Morning," : (hour < 18 ? "Good Afternoon," : "Good Evening,")
            completion(.success(.init(greeting: g, name: name)))
        }
    }

    func loadWeeklyStats(completion: @escaping (Result<HomeStatsVM, Error>) -> Void) {
        // Stub aman: pakai run/rides lokal (nanti bisa diganti hit repo)
        trackingRepo.getRuns { _ in
            // contoh series 7 hari
            let series: [Double] = [3.2, 5.1, 0.0, 7.8, 4.2, 9.0, 6.3]
            let total = series.reduce(0, +)
            let vm = HomeStatsVM(
                title: "Running last week",
                totalText: String(format: "%.2f KM", total),
                deltaText: "↑ 12% vs last week",
                series: series
            )
            completion(.success(vm))
        }
    }
}

