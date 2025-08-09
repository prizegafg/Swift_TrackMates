//
//  SessionManager.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 08/08/25.
//

// TrackMates/Core/Session/SessionManager.swift

import UIKit
import Combine
import FirebaseAuth

enum AppRoute {
    case onboarding
    case login
    case home
}

struct SessionState {
    let hasSeenOnboarding: Bool
    let isAuthenticated: Bool
}

final class SessionManager {
    static let shared = SessionManager()

    private let sessionRepo: SessionRepositoryProtocol
    private let sessionService: SessionServiceProtocol

    // local repos untuk pre-load setelah login
    private let userQueryRepo: UserRepositoryProtocol
    private let trackingRepo: TrackingRepositoryProtocol
    private let caloryRepo: CaloryRepositoryProtocol
    private let eventsRepo: EventsRepositoryProtocol

    private init(sessionRepo: SessionRepositoryProtocol = SessionRepository(),
                 sessionService: SessionServiceProtocol = SessionService(),
                 userQueryRepo: UserRepositoryProtocol = UserRepository(),
                 trackingRepo: TrackingRepositoryProtocol = TrackingRepository(),
                 caloryRepo: CaloryRepositoryProtocol = CaloryRepository(),
                 eventsRepo: EventsRepositoryProtocol = EventsRepository()) {
        self.sessionRepo = sessionRepo
        self.sessionService = sessionService
        self.userQueryRepo = userQueryRepo
        self.trackingRepo = trackingRepo
        self.caloryRepo = caloryRepo
        self.eventsRepo = eventsRepo
    }

    // MARK: - Entry

    func resolveInitialRoot() -> UIViewController {
        let state = SessionState(
            hasSeenOnboarding: sessionRepo.hasSeenOnboarding(),
            isAuthenticated: sessionService.isAuthenticated()
        )
        switch route(for: state) {
        case .onboarding:
            return OnboardingRouter.makeModule(didFinish: { [weak self] in
                self?.markOnboardingSeen()
                self?.routeAfterOnboarding()
            })
        case .login:
            return LoginRouter.makeModule()
        case .home:
            // udah login -> pre-load data lokal
            preloadLocalData()
            return HomeRouter.makeModule()
        }
    }

    func markOnboardingSeen() {
        sessionRepo.setHasSeenOnboarding(true)
    }

    // dipanggil saat onboarding selesai
    private func routeAfterOnboarding() {
        let vc: UIViewController
        if sessionService.isAuthenticated() {
            preloadLocalData()
            vc = HomeRouter.makeModule()
        } else {
            vc = LoginRouter.makeModule()
        }
        swapRoot(to: vc)
    }

    // dipanggil presenter login/register ketika sukses auth
    func didLogin() {
        preloadLocalData()
        swapRoot(to: HomeRouter.makeModule())
    }

    // MARK: - Preload

    private func preloadLocalData() {
        // aman: non-blocking; error di-log saja supaya tidak ganggu UX
        userQueryRepo.current { _ in }

        trackingRepo.getRuns { _ in }
        trackingRepo.getRides { _ in }

        caloryRepo.getAll { _ in }

        eventsRepo.getPastEvents { _ in }
        eventsRepo.getSharedMedia { _ in }
    }

    // MARK: - Root swap

    private func swapRoot(to vc: UIViewController) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        window.setRoot(vc, animated: true)
    }

    // MARK: - Helpers

    private func route(for state: SessionState) -> AppRoute {
        if !state.hasSeenOnboarding { return .onboarding }
        return state.isAuthenticated ? .home : .login
    }
}
