//
//  LoginView.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import UIKit
import Combine

// MARK: - Login (View)
final class Login: UIViewController {
    var presenter: LoginPresenterProtocol!
    private var cancellables = Set<AnyCancellable>()

    // MARK: UI Elements
    let overlayView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.85)
        v.layer.cornerRadius = 24
        v.layer.masksToBounds = false
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.08
        v.layer.shadowRadius = 16
        v.layer.shadowOffset = CGSize(width: 0, height: 8)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Welcome Back!"
        lbl.font = .systemFont(ofSize: 24, weight: .bold)
        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    let subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Sign in to Track Mates to start your run or ride session."
        lbl.font = .systemFont(ofSize: 14, weight: .regular)
        lbl.textColor = .darkGray
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    let emailField = Login.makeField(placeholder: "Email", keyboard: .emailAddress)
    let passwordField = Login.makeField(placeholder: "Password", secure: true)

    let loginButton = Login.makeButton(title: "Sign In")
    let registerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Create New Account", for: .normal)
        btn.setTitleColor(.systemGreen, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if presenter == nil {
            presenter = LoginPresenter(interactor: LoginInteractor())
        }
        setupBackground()
        setupUI()
        setupLayout()
        setupBinding()
        setupActions()
        setupKeyboardDismiss()
    }
}

// MARK: - UI Factory
private extension Login {
    static func makeField(placeholder: String, keyboard: UIKeyboardType = .default, secure: Bool = false) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.autocapitalizationType = .none
        tf.keyboardType = keyboard
        tf.isSecureTextEntry = secure
        tf.borderStyle = .roundedRect
        tf.backgroundColor = UIColor(white: 0.97, alpha: 1)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return tf
    }

    static func makeButton(title: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.backgroundColor = .systemGreen
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return btn
    }
}

// MARK: - Background Setup
private extension Login {
    func setupBackground() {
        let bg = UIImageView()
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.contentMode = .scaleAspectFill
        bg.clipsToBounds = true
        bg.image = UIImage(named: preferredLoginBGName())

        // taruh paling belakang
        view.addSubview(bg)
        view.sendSubviewToBack(bg)

        NSLayoutConstraint.activate([
            bg.topAnchor.constraint(equalTo: view.topAnchor),
            bg.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bg.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    func preferredLoginBGName() -> String {
        switch traitCollection.userInterfaceIdiom {
        case .pad:
            return "loginbg_ipad"
        case .phone:
            return "loginbg_iphone"
        case .mac:
            // Mac Catalyst: pakai iPad biar rasio lebih aman
            return "loginbg_ipad"
        default:
            return "loginbg_iphone"
        }
    }
}


// MARK: - Setup UI
private extension Login {
    func setupUI() {
        view.backgroundColor = .black
        view.addSubview(overlayView)
        view.addSubview(cardView)

        [titleLabel, subtitleLabel, emailField, passwordField, loginButton, registerButton]
            .forEach { cardView.addSubview($0) }
    }
}

// MARK: - Layout
private extension Login {
    func setupLayout() {
        NSLayoutConstraint.activate([
            // overlay
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // card
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            // title
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),

            // subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),

            // email
            emailField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 28),
            emailField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            emailField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),

            // password
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 14),
            passwordField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            passwordField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),

            // login button
            loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 22),
            loginButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            loginButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),

            // register button
            registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 14),
            registerButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -18),
            registerButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor)
        ])
    }
}

// MARK: - Binding (Combine)
private extension Login {
    func setupBinding() {
        presenter.loginResultPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] user in
                guard let _ = user else { return }
                // TODO: navigate to Home via Router kalau sudah di-wire
            }
            .store(in: &cancellables)

        presenter.errorPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                guard let error = error else { return }
                // TODO: tampilkan alert/toast
                print("Login error:", error)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Actions
private extension Login {
    func setupActions() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
    }

    @objc func loginButtonTapped() {
        presenter.login(
            email: (emailField.text ?? "").trimmed,
            password: (passwordField.text ?? "")
        )
    }

    @objc func registerButtonTapped() {
        // Idealnya lewat Router: LoginRouter.navigateToRegister(from: self)
        // Disini tinggal panggil via Presenter kalau kamu expose methodnya,
        // atau nanti di-wire oleh Router.
        // Contoh no-op sementara:
        print("Register tapped")
    }
}

// MARK: - Helpers
private extension Login {
    func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
