//
//  SessionManager.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 08/08/25.
//


import UIKit
import Combine
import FirebaseAuth
import CoreData

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
    private let userRepo: UserRepositoryProtocol
    private let trackingRepo: TrackingRepositoryProtocol
    private let caloryRepo: CaloryRepositoryProtocol
    private let eventsRepo: EventsRepositoryProtocol

    private init(sessionRepo: SessionRepositoryProtocol = SessionRepository(),
                 sessionService: SessionServiceProtocol = SessionService(),
                 userRepo: UserRepositoryProtocol = UserRepository(),
                 trackingRepo: TrackingRepositoryProtocol = TrackingRepository(),
                 caloryRepo: CaloryRepositoryProtocol = CaloryRepository(),
                 eventsRepo: EventsRepositoryProtocol = EventsRepository()) {
        self.sessionRepo = sessionRepo
        self.sessionService = sessionService
        self.userRepo = userRepo
        self.trackingRepo = trackingRepo
        self.caloryRepo = caloryRepo
        self.eventsRepo = eventsRepo
    }

    func resolveInitialRoot() -> UIViewController {
        ensureFreshInstallReset()

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
            preloadLocalData()
            return MainTabsRouter.makeModule()
        }
    }

    func markOnboardingSeen() {
        sessionRepo.setHasSeenOnboarding(true)
    }

    private func routeAfterOnboarding() {
        let vc: UIViewController
        if sessionService.isAuthenticated() {
            preloadLocalData()
            vc = MainTabsRouter.makeModule()
        } else {
            vc = LoginRouter.makeModule()
        }
        swapRoot(to: vc)
    }

    func didLogin() {
        preloadLocalData()
        swapRoot(to: MainTabsRouter.makeModule())
    }

    private func preloadLocalData() {
        if let uid = sessionService.currentUserId() {
            userRepo.get(uid) { _ in }
        }
        trackingRepo.getTracking { _ in }
        caloryRepo.getAll { _ in }
        eventsRepo.getPastEvents { _ in }
        eventsRepo.getSharedMedia { _ in }
    }

    private func swapRoot(to vc: UIViewController) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        window.setRoot(vc, animated: true)
    }

    private func route(for state: SessionState) -> AppRoute {
        if !state.hasSeenOnboarding { return .onboarding }
        guard state.isAuthenticated else { return .login }
        return hasLocalUserSync() ? .home : .login
    }

    private func hasLocalUserSync() -> Bool {
        let ctx = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let req = NSFetchRequest<NSManagedObject>(entityName: "User")
        req.fetchLimit = 1
        return (try? ctx.fetch(req).first) != nil
    }

    private func ensureFreshInstallReset() {
        let key = "tm_first_install_done"
        let d = UserDefaults.standard
        guard d.bool(forKey: key) == false else { return }

        try? Auth.auth().signOut()

        userRepo.wipeAll { _ in }

        d.set(true, forKey: key)
    }
}
