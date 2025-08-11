//
//  OnboardingPresenter.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 10/08/25.
//

import UIKit

struct OnboardingSlideVM {
    let title: String
    let desc: String
    let imageName: String
}

enum FooterState {
    case controls(canBack: Bool)     // Back + Dots + Next
    case cta                         // “Understand”
}

protocol OnboardingViewProtocol: AnyObject {
    func reload()
    func setPage(_ index: Int, total: Int)
    func setFooter(_ state: FooterState)
    func scroll(to index: Int) // view-only scrolling, no state
}

protocol OnboardingPresenterProtocol: AnyObject {
    var count: Int { get }
    func attach(view: OnboardingViewProtocol)
    func viewDidLoad()
    func slide(at index: Int) -> OnboardingSlideVM
    func next()
    func back()
    func didScroll(to index: Int)
    func tapCTA()
}

final class OnboardingPresenter: OnboardingPresenterProtocol {
     
    private weak var view: OnboardingViewProtocol?
    private let router: OnboardingRouterProtocol

    private let slides: [OnboardingSlideVM] = [
        .init(
            title: "Track Your Every Move",
            desc: "Record your runs and rides with precise GPS.\nMonitor distance, speed, duration, and calories burned — all in real time.",
            imageName: "onboard_tracking"
        ),
        .init(
            title: "Achieve Your Fitness Goals",
            desc: "Stay on top of your daily calorie intake and reach your health targets.\nWe calculate everything automatically from your activities and food logs.",
            imageName: "onboard_calories"
        ),
        .init(
            title: "Run Together, Stay Motivated",
            desc: "Share your routes and results with friends, or join group runs for extra support.\nMake every workout more fun and consistent.",
            imageName: "onboard_share"
        )
    ]

    private var index = 0 {
        didSet { updateUI() }
    }

    init(router: OnboardingRouterProtocol) { self.router = router }

    var count: Int { slides.count }

    func attach(view: OnboardingViewProtocol) { self.view = view }

    func viewDidLoad() {
        view?.reload()
        updateUI()
    }

    func slide(at i: Int) -> OnboardingSlideVM { slides[i] }

    func next() {
        if index == slides.count - 1 { router.finish(); return }
        index = min(index + 1, slides.count - 1)
        view?.scroll(to: index)
    }

    func back() {
        index = max(index - 1, 0)
        view?.scroll(to: index)
    }

    func didScroll(to i: Int) {
        guard i != index, (0..<slides.count).contains(i) else { return }
        index = i
    }
    
    func tapCTA() {
        router.finish()
    }

    private func updateUI() {
        view?.setPage(index, total: slides.count)
        let isLast = (index == slides.count - 1)
        if isLast {
            view?.setFooter(.cta)
        } else {
            view?.setFooter(.controls(canBack: index > 0))
        }
    }
}
