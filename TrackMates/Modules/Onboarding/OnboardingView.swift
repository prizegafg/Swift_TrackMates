//
//  OnboardingView.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 10/08/25.
//

import UIKit

final class OnboardingView: UIViewController {
    var presenter: OnboardingPresenterProtocol!

    // Gradient
    private let gradient = CAGradientLayer()

    // Collection
    private let layout: UICollectionViewFlowLayout = {
        let l = UICollectionViewFlowLayout()
        l.scrollDirection = .horizontal
        l.minimumLineSpacing = 0
        return l
    }()
    private lazy var collection: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(Cell.self, forCellWithReuseIdentifier: "cell")
        return cv
    }()

    // Bottom controls (stack yang bisa di-swap dengan CTA)
    private let backBtn: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Back", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        b.layer.cornerRadius = 12
        b.translatesAutoresizingMaskIntoConstraints = false
        b.heightAnchor.constraint(equalToConstant: 44).isActive = true
        b.widthAnchor.constraint(equalToConstant: 96).isActive = true
        return b
    }()
    private let nextBtn: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Next", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor(red: 0.62, green: 0.82, blue: 0.23, alpha: 1)
        b.layer.cornerRadius = 12
        b.translatesAutoresizingMaskIntoConstraints = false
        b.heightAnchor.constraint(equalToConstant: 44).isActive = true
        b.widthAnchor.constraint(equalToConstant: 120).isActive = true
        return b
    }()
    private let dots: UIPageControl = {
        let p = UIPageControl()
        p.translatesAutoresizingMaskIntoConstraints = false
        p.currentPageIndicatorTintColor = UIColor(red: 0.62, green: 0.82, blue: 0.23, alpha: 1)
        p.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.45)
        return p
    }()

    // CTA footer (hidden by default)
    private let ctaBtn: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Understand", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor(red: 0.62, green: 0.82, blue: 0.23, alpha: 1)
        b.layer.cornerRadius = 12
        b.translatesAutoresizingMaskIntoConstraints = false
        b.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return b
    }()

    // Containers
    private let controlsContainer = UIView()
    private let ctaContainer = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        buildUI()
        bindActions()
        presenter.viewDidLoad()
        view.bringSubviewToFront(ctaContainer)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
        layout.itemSize = collection.bounds.size
    }
}

// MARK: - View <-> Presenter
extension OnboardingView: OnboardingViewProtocol {
    func reload() {
        dots.numberOfPages = presenter.count
        collection.reloadData()
    }

    func setPage(_ index: Int, total: Int) {
        dots.currentPage = index
    }

    // Animasi morph footer (controls <-> CTA)
    func setFooter(_ state: FooterState) {
        switch state {
        case .controls(let canBack):
            backBtn.isEnabled = canBack
            backBtn.alpha = canBack ? 1.0 : 0.5

            // animate crossfade + slide
            if ctaContainer.alpha > 0 || !ctaContainer.isHidden {
                UIView.animate(withDuration: 0.28, delay: 0, options: [.curveEaseInOut]) {
                    self.ctaContainer.alpha = 0
                    self.ctaContainer.transform = CGAffineTransform(translationX: 0, y: 10)
                } completion: { _ in
                    self.ctaContainer.isHidden = true
                    self.controlsContainer.isHidden = false
                    self.controlsContainer.transform = CGAffineTransform(translationX: 0, y: 10)
                    self.controlsContainer.alpha = 0
                    UIView.animate(withDuration: 0.28, delay: 0, options: [.curveEaseInOut]) {
                        self.controlsContainer.alpha = 1
                        self.controlsContainer.transform = .identity
                    }
                }
            }
        case .cta:
            if controlsContainer.alpha > 0 || !controlsContainer.isHidden {
                UIView.animate(withDuration: 0.28, delay: 0, options: [.curveEaseInOut]) {
                    self.controlsContainer.alpha = 0
                    self.controlsContainer.transform = CGAffineTransform(translationX: 0, y: 10)
                } completion: { _ in
                    self.controlsContainer.isHidden = true
                    self.view.bringSubviewToFront(self.ctaContainer)
                    self.ctaBtn.isHidden = false
                    self.ctaContainer.isHidden = false
                    self.ctaBtn.alpha = 1
                    self.ctaContainer.alpha = 0
                    self.ctaContainer.transform = CGAffineTransform(translationX: 0, y: 10)
                    UIView.animate(withDuration: 0.28, delay: 0,
                                   usingSpringWithDamping: 0.9, initialSpringVelocity: 0.6) {
                        self.ctaContainer.alpha = 1
                        self.ctaContainer.transform = .identity
                    }
                }
            }
        }
    }

    func scroll(to index: Int) {
        let idx = IndexPath(item: index, section: 0)
        collection.scrollToItem(at: idx, at: .centeredHorizontally, animated: true)
    }
}

// MARK: - Collection + cell animation
extension OnboardingView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { presenter.count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let c = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! Cell
        c.apply(presenter.slide(at: indexPath.item))
        return c
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        presenter.didScroll(to: page)
    }

    // simple slide-in animation saat willDisplay
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0
        cell.transform = CGAffineTransform(translationX: 30, y: 0)
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.6) {
            cell.alpha = 1
            cell.transform = .identity
        }
    }
}

// MARK: - Private UI
private extension OnboardingView {
    func setupGradient() {
        gradient.colors = [
            UIColor(red: 0.09, green: 0.11, blue: 0.18, alpha: 1).cgColor,
            UIColor(red: 0.20, green: 0.60, blue: 0.40, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
    }

    func buildUI() {
        controlsContainer.translatesAutoresizingMaskIntoConstraints = false
        ctaContainer.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(collection)
        view.addSubview(controlsContainer)
        view.addSubview(ctaContainer)

        // controls stack: Back — Dots — Next
        controlsContainer.addSubview(backBtn)
        controlsContainer.addSubview(dots)
        controlsContainer.addSubview(nextBtn)

        // CTA
        ctaContainer.addSubview(ctaBtn)
        ctaContainer.isHidden = true
        ctaContainer.alpha = 0


        NSLayoutConstraint.activate([
            collection.topAnchor.constraint(equalTo: view.topAnchor),
            collection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collection.bottomAnchor.constraint(equalTo: controlsContainer.topAnchor, constant: -24),

            // Controls container
            controlsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            controlsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            controlsContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            controlsContainer.heightAnchor.constraint(equalToConstant: 44),

            backBtn.leadingAnchor.constraint(equalTo: controlsContainer.leadingAnchor),
            backBtn.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),

            nextBtn.trailingAnchor.constraint(equalTo: controlsContainer.trailingAnchor),
            nextBtn.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),

            dots.centerXAnchor.constraint(equalTo: controlsContainer.centerXAnchor),
            dots.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),

            // CTA container
            ctaContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            ctaContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            ctaContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            ctaBtn.topAnchor.constraint(equalTo: ctaContainer.topAnchor),
            ctaBtn.leadingAnchor.constraint(equalTo: ctaContainer.leadingAnchor),
            ctaBtn.trailingAnchor.constraint(equalTo: ctaContainer.trailingAnchor),
            ctaBtn.bottomAnchor.constraint(equalTo: ctaContainer.bottomAnchor)
        ])
    }

    func bindActions() {
        nextBtn.addTarget(self, action: #selector(nextTap), for: .touchUpInside)
        backBtn.addTarget(self, action: #selector(backTap), for: .touchUpInside)
        ctaBtn.addTarget(self, action: #selector(ctaTap), for: .touchUpInside)
    }

    @objc func nextTap() { presenter.next() }
    @objc func backTap() { presenter.back() }
    @objc func ctaTap()  { presenter.tapCTA() }
}

// MARK: - Cell (unchanged except small polish)
private final class Cell: UICollectionViewCell {
    private let img = UIImageView()
    private let title = UILabel()
    private let desc = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false

        title.font = .boldSystemFont(ofSize: 22)
        title.textColor = .white
        title.numberOfLines = 0
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false

        desc.font = .systemFont(ofSize: 15)
        desc.textColor = UIColor.white.withAlphaComponent(0.86)
        desc.numberOfLines = 0
        desc.textAlignment = .center
        desc.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(img)
        contentView.addSubview(title)
        contentView.addSubview(desc)

        NSLayoutConstraint.activate([
            img.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 48),
            img.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            img.heightAnchor.constraint(equalToConstant: 220),
            img.widthAnchor.constraint(equalTo: img.heightAnchor),

            title.topAnchor.constraint(equalTo: img.bottomAnchor, constant: 28),
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            desc.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 12),
            desc.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            desc.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func apply(_ vm: OnboardingSlideVM) {
        img.image = UIImage(named: vm.imageName)
        title.text = vm.title
        desc.text  = vm.desc
    }
}
