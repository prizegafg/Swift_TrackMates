//
//  SessionManager.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 08/08/25.
//


// --- TrackMates/Core/Session/SessionManager.swift ---

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

    // Dependencies (pattern service + repo)
    private let sessionRepo: SessionRepositoryProtocol
    private let sessionService: SessionServiceProtocol
    private let userRepo: UserRepositoryProtocol
    private let trackingRepo: TrackingRepositoryProtocol
    private let caloryRepo: CaloryRepositoryProtocol
    private let eventsRepo: EventsRepositoryProtocol

    // Gunakan satu initializer privat untuk singleton
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

    // Entry: tentukan root awal
    func resolveInitialRoot() -> UIViewController {
        // Pastikan fresh-install reset: keychain auth & Core Data dibersihkan saat pertama kali run setelah install
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
            return HomeRouter.makeModule()
        }
    }

    func markOnboardingSeen() {
        sessionRepo.setHasSeenOnboarding(true)
    }

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

    func didLogin() {
        preloadLocalData()
        swapRoot(to: HomeRouter.makeModule())
    }

    private func preloadLocalData() {
        if let uid = sessionService.currentUserId() {
            userRepo.get(uid) { _ in } // warm up cache lokal user
        }
        trackingRepo.getRuns { _ in }
        trackingRepo.getRides { _ in }
        caloryRepo.getAll { _ in }
        eventsRepo.getPastEvents { _ in }
        eventsRepo.getSharedMedia { _ in }
    }

    private func swapRoot(to vc: UIViewController) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        window.setRoot(vc, animated: true)
    }

    // ⚠️ Sinkron: jangan pakai completion `done(...)`
    private func route(for state: SessionState) -> AppRoute {
        if !state.hasSeenOnboarding { return .onboarding }
        guard state.isAuthenticated else { return .login }
        // Sudah login? Pastikan lokal punya user. Kalau kosong, lempar ke Login agar fetch ulang/masuk ulang.
        return hasLocalUserSync() ? .home : .login
    }

    // Cek local user secara sinkron (fetch 1 baris)
    private func hasLocalUserSync() -> Bool {
        let ctx = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let req = NSFetchRequest<NSManagedObject>(entityName: "User")
        req.fetchLimit = 1
        return (try? ctx.fetch(req).first) != nil
    }

    // Reset khusus first run setelah INSTALL (bukan hanya first open app)
    // Mengatasi kasus: uninstall → install; FirebaseAuth masih “login” karena disimpan di Keychain.
    private func ensureFreshInstallReset() {
        let key = "tm_first_install_done"
        let d = UserDefaults.standard
        guard d.bool(forKey: key) == false else { return }

        // 1) Hapus sesi auth yang nempel di Keychain
        try? Auth.auth().signOut()

        // 2) Bersihkan seluruh Core Data
        userRepo.wipeAll { _ in }

        // 3) Tanda sudah di-run
        d.set(true, forKey: key)
    }
}
