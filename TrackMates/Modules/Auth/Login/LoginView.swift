//
//  LoginView.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import UIKit
import Combine

final class LoginView: UIViewController {
    var presenter: LoginPresenterProtocol!
    private var cancellables = Set<AnyCancellable>()

    // MARK: UI Tokens
    private enum UI {
        static let cardSide: CGFloat = 32
        static let hInset: CGFloat  = 18
        static let vTitle: CGFloat  = 32
        static let vGapBig: CGFloat = 28
        static let vGap: CGFloat    = 14
        static let vBtnTop: CGFloat = 22
        static let vBottom: CGFloat = 18
    }

    // MARK: Views
    private let overlayView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.black.withAlphaComponent(0.30)
        return v
    }()

    private let cardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.white.withAlphaComponent(0.85)
        v.layer.cornerRadius = 24
        v.layer.masksToBounds = false
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.08
        v.layer.shadowRadius = 16
        v.layer.shadowOffset = CGSize(width: 0, height: 8)
        return v
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Welcome Back!"
        lbl.font = .systemFont(ofSize: 24, weight: .bold)
        lbl.textColor = .tmLabelPrimary
        lbl.textAlignment = .center
        return lbl
    }()

    private let subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Sign in to Track Mates to start your run or ride session."
        lbl.font = .systemFont(ofSize: 14, weight: .regular)
        lbl.textColor = .tmLabelSecondary
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()

    // Reusable components
    private let emailField    = DesignTextField.field("Email", keyboard: .emailAddress)
    private let passwordField = DesignTextField.secure("Password")
    private lazy var showLoginPassBtn: UIButton = DesignTextField.addEyeToggle(to: passwordField)

    private let loginButton    = DesignButton.primary("Sign In")
    private let registerButton = DesignButton.link("Create New Account")

    private let activity: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(style: .medium)
        a.translatesAutoresizingMaskIntoConstraints = false
        a.hidesWhenStopped = true
        return a
    }()

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if presenter == nil { // safeguard for router-less init (dev time)
            presenter = LoginPresenter(interactor: LoginInteractor(), router: LoginRouter())
        }
        setupBackground()
        buildUI()
        layoutUI()
        bindPresenter()
        bindActions()
        enableKeyboardDismiss()
        presenter.attach(view: self)
    }
}

// MARK: - View Protocol
extension LoginView: LoginViewProtocol {
    var vc: UIViewController { self }

    func setLoading(_ loading: Bool) {
        loading ? activity.startAnimating() : activity.stopAnimating()
        view.isUserInteractionEnabled = !loading
        loginButton.alpha = loading ? 0.7 : 1
    }

    func showAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}

// MARK: - Setup UI
private extension LoginView {
    func setupBackground() {
        let bg = UIImageView()
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.contentMode = .scaleAspectFill
        bg.clipsToBounds = true
        bg.image = UIImage(named: preferredLoginBGName())
        view.addSubview(bg)
        NSLayoutConstraint.activate([
            bg.topAnchor.constraint(equalTo: view.topAnchor),
            bg.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bg.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        view.sendSubviewToBack(bg)
    }

    func preferredLoginBGName() -> String {
        switch traitCollection.userInterfaceIdiom {
        case .pad, .mac: return "loginbg_ipad"
        case .phone:     return "loginbg_iphone"
        default:         return "loginbg_iphone"
        }
    }

    func buildUI() {
        view.backgroundColor = .black
        view.addSubview(overlayView)
        view.addSubview(cardView)

        [titleLabel, subtitleLabel, emailField, passwordField, loginButton, registerButton, activity]
            .forEach { cardView.addSubview($0) }

        showLoginPassBtn = DesignTextField.addEyeToggle(to: passwordField)
    }

    func layoutUI() {
        NSLayoutConstraint.activate([
            // overlay
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // card
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UI.cardSide),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UI.cardSide),

            // title
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: UI.vTitle),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: UI.hInset),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -UI.hInset),

            // subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: UI.hInset),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -UI.hInset),

            // email
            emailField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: UI.vGapBig),
            emailField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: UI.hInset),
            emailField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -UI.hInset),

            // password
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: UI.vGap),
            passwordField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: UI.hInset),
            passwordField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -UI.hInset),

            // login button
            loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: UI.vBtnTop),
            loginButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: UI.hInset),
            loginButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -UI.hInset),

            // register link
            registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 14),
            registerButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            registerButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -UI.vBottom),

            // activity on top of login button
            activity.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),
            activity.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor),
        ])
    }
}

// MARK: - Bindings & Actions
private extension LoginView {
    func bindPresenter() {
        presenter.loginResultPublisher
            .receive(on: RunLoop.main)
            .sink { _ in /* no-op, router handles navigation */ }
            .store(in: &cancellables)

        presenter.errorPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.passwordField.becomeFirstResponder() }
            .store(in: &cancellables)
    }

    func bindActions() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        // eye button action sudah di-handle oleh DesignTextField.addEyeToggle(to:)
    }

    @objc func loginButtonTapped() {
        presenter.onTapLogin(
            email: (emailField.text ?? "").trimmed,
            password: (passwordField.text ?? "")
        )
    }

    @objc func registerButtonTapped() {
        presenter.onTapRegister()
    }
}

// MARK: - Keyboard dismiss
private extension LoginView {
    func enableKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
