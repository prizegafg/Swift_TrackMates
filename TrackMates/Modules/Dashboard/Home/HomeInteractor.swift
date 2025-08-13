//
//  HomeInteractor.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import Foundation

struct HomeHeaderVM {
    let greeting: String
    let name: String
}

struct HomeStatsVM {
    let title: String
    let totalText: String
    let deltaText: String
    let series: [Double]
}

struct HomeChartVM {
    let days: [String]
    let run: [Double]
    let ride: [Double]
    let walk: [Double]
}

protocol HomeInteractorProtocol {
    func logout(completion: @escaping (Result<Void, Error>) -> Void)
    func loadHeader(completion: @escaping (Result<HomeHeaderVM, Error>) -> Void)
    func loadWeeklyStats(completion: @escaping (Result<HomeStatsVM, Error>) -> Void)
    func loadWeeklyRank(completion: @escaping (Result<[RankItemVM], Error>) -> Void)
    func loadWeeklyChart(completion: @escaping (Result<HomeChartVM, Error>) -> Void)
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
        trackingRepo.getRuns { _ in
            let series: [Double] = [13.2, 8.25, 0.0, 7.8, 4.2, 9.0, 6.3]
            let total = series.reduce(0, +)
            let vm = HomeStatsVM(
                title: "Last Week Activity",
                totalText: String(format: "%.2f KM", total),
                deltaText: "↑ 12% vs last week",
                series: series
            )
            completion(.success(vm))
        }
    }
    
    func loadWeeklyRank(completion: @escaping (Result<[RankItemVM], Error>) -> Void) {
        let items: [RankItemVM] = [
            .init(rank: 1, name: "Andy William", distanceText: "59.23 KM"),
            .init(rank: 2, name: "You",          distanceText: "48.75 KM"),
            .init(rank: 3, name: "Thomas Speed", distanceText: "32.07 KM"),
            .init(rank: 4, name: "Jolly Rodger", distanceText: "25.12 KM"),
            .init(rank: 5, name: "Jennie McPhiss", distanceText: "15.25 KM")
        ]
        completion(.success(items))
    }
    
    func loadWeeklyChart(completion: @escaping (Result<HomeChartVM, Error>) -> Void) {
        let days = ["M","T","W","T","F","S","S"]
        let run  = [5.4, 6.1, 0.0, 6.2, 4.0, 7.5, 6.4]
        let ride = [2.0, 4.9, 11.35, 9.0, 0.0, 12.3, 4.8]
        let walk = [1.6, 0.8, 0.3, 0.0, 1.0, 0.0, 1.2]
        completion(.success(.init(days: days, run: run, ride: ride, walk: walk)))
    }
}

