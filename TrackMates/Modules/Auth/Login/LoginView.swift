//
//  LoginView.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import UIKit
import Combine

// MARK: - Login (View)
final class LoginView: UIViewController {
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

    let emailField = LoginView.makeField(placeholder: "Email", keyboard: .emailAddress)
    let passwordField = LoginView.makeField(placeholder: "Password", secure: true)
    private lazy var showLoginPassBtn: UIButton = LoginView.makeEyeButton()

    let loginButton = LoginView.makeButton(title: "Sign In")
    let registerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Create New Account", for: .normal)
        btn.setTitleColor(.systemGreen, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let activity = UIActivityIndicatorView(style: .medium)

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if presenter == nil {
            presenter = LoginPresenter(interactor: LoginInteractor(), router: LoginRouter())
        }
        setupBackground()
        setupUI()
        setupLayout()
        setupBinding()
        setupActions()
        setupKeyboardDismiss()
        
        presenter.attach(view: self)
    }
}

// MARK: - LoginViewProtocol
extension LoginView: LoginViewProtocol {
    var vc: UIViewController { self }

    func setLoading(_ loading: Bool) {
        if loading { activity.startAnimating() } else { activity.stopAnimating() }
        view.isUserInteractionEnabled = !loading
        loginButton.alpha = loading ? 0.7 : 1
    }

    func showAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}

// MARK: - UI Factory
private extension LoginView {
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
    
    static func makeEyeButton() -> UIButton {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        btn.tintColor = .secondaryLabel
        btn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        btn.accessibilityLabel = "Show or hide password"
        return btn
    }
}

// MARK: - Background Setup
private extension LoginView {
    func setupBackground() {
        let bg = UIImageView()
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.contentMode = .scaleAspectFill
        bg.clipsToBounds = true
        bg.image = UIImage(named: preferredLoginBGName())

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
            return "loginbg_ipad"
        default:
            return "loginbg_iphone"
        }
    }
}


// MARK: - Setup UI
private extension LoginView {
    func setupUI() {
        view.backgroundColor = .black
        view.addSubview(overlayView)
        view.addSubview(cardView)

        [titleLabel, subtitleLabel, emailField, passwordField, loginButton, registerButton]
            .forEach { cardView.addSubview($0) }
        passwordField.rightView = showLoginPassBtn
        passwordField.rightViewMode = .always

    }
}

// MARK: - Layout
private extension LoginView {
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
private extension LoginView {
    func setupBinding() {
        presenter.loginResultPublisher
            .receive(on: RunLoop.main)
            .sink { _ in  }
            .store(in: &cancellables)
        
        presenter.errorPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                
                self?.passwordField.becomeFirstResponder()
            }
            .store(in: &cancellables)
    }
}

// MARK: - Actions
private extension LoginView {
    func setupActions() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        showLoginPassBtn.addTarget(self, action: #selector(toggleLoginPassword), for: .touchUpInside)

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
    
    @objc func toggleLoginPassword() {
        toggleSecureEntry(passwordField, button: showLoginPassBtn)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Helpers
private extension LoginView {
    func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func toggleSecureEntry(_ tf: UITextField, button: UIButton) {
        let wasFirstResponder = tf.isFirstResponder
        let existingText = tf.text

        tf.isSecureTextEntry.toggle()
        if wasFirstResponder { tf.resignFirstResponder() }
        tf.text = nil
        tf.text = existingText
        if wasFirstResponder { tf.becomeFirstResponder() }

        let img = tf.isSecureTextEntry ? "eye.slash" : "eye"
        button.setImage(UIImage(systemName: img), for: .normal)
    }

    
}
