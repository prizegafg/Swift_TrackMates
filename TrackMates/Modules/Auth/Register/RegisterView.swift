//
//  RegisterView.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import UIKit
import Combine

final class RegisterView: UIViewController {
    var presenter: RegisterPresenterProtocol!
    private var cancellables = Set<AnyCancellable>()

    let scrollView = UIScrollView()
    let contentView = UIView()
    let cardView = UIView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let usernameField = RegisterView.makeField(placeholder: "Username")
    let emailField = RegisterView.makeField(placeholder: "Email", keyboard: .emailAddress)
    let dobField = RegisterView.makeField(placeholder: "Date of Birth")
    let passwordField = RegisterView.makeField(placeholder: "Password", secure: true)
    let repeatPasswordField = RegisterView.makeField(placeholder: "Repeat Password", secure: true)
    let registerButton = UIButton(type: .system)
    private let loginLinkButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Already Have Account? Login", for: .normal)
        btn.setTitleColor(.systemGreen, for: .normal)
        btn.backgroundColor = .clear
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    let dobPicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.maximumDate = Date()
        if #available(iOS 13.4, *) { dp.preferredDatePickerStyle = .wheels }
        return dp
    }()

    private let activity = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setupDOBPicker()
        setupBinding()
        setupActions()
        if let v = self as? RegisterViewProtocol { /* no-op, just for clarity */ }
        presenter.attach(view: self)
    }
}

extension RegisterView: RegisterViewProtocol {
    var vc: UIViewController { self }

    func showAlert(title: String, message: String, onOK: @escaping () -> Void) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default) { _ in onOK() })
        present(a, animated: true)
    }

    func setLoading(_ loading: Bool) {
        loading ? activity.startAnimating() : activity.stopAnimating()
        registerButton.isEnabled = !loading
        loginLinkButton.isEnabled = !loading
    }
}

private extension RegisterView {
    static func makeField(placeholder: String, keyboard: UIKeyboardType = .default, secure: Bool = false) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.autocapitalizationType = .none
        tf.isSecureTextEntry = secure
        tf.keyboardType = keyboard
        tf.backgroundColor = UIColor(white: 0.97, alpha: 1)
        tf.borderStyle = .roundedRect
        tf.layer.cornerRadius = 12
        tf.font = .systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }

    func setupUI() {
        view.backgroundColor = UIColor(red: 0.09, green: 0.11, blue: 0.18, alpha: 1)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 24
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.07
        cardView.layer.shadowOffset = CGSize(width: 0, height: 8)
        cardView.layer.shadowRadius = 24

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Registration in to your Account"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = UIColor(white: 0.15, alpha: 1)
        titleLabel.textAlignment = .center

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Effortlessly register, access your account, and enjoy seamless convenience!"
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textColor = .gray
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center

        registerButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.setTitle("Registration", for: .normal)
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.backgroundColor = UIColor(red: 0.62, green: 0.82, blue: 0.23, alpha: 1)
        registerButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        registerButton.layer.cornerRadius = 12
        registerButton.heightAnchor.constraint(equalToConstant: 48).isActive = true

        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.hidesWhenStopped = true

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(cardView)
        [titleLabel, subtitleLabel, usernameField, emailField, dobField, passwordField, repeatPasswordField, registerButton, loginLinkButton, activity]
            .forEach { cardView.addSubview($0) }
    }

    func setupLayout() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            cardView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 44),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),
            cardView.bottomAnchor.constraint(equalTo: loginLinkButton.bottomAnchor, constant: 36),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 36),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 22),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -22),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),

            usernameField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            usernameField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            usernameField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            usernameField.heightAnchor.constraint(equalToConstant: 44),

            emailField.topAnchor.constraint(equalTo: usernameField.bottomAnchor, constant: 14),
            emailField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            emailField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            emailField.heightAnchor.constraint(equalToConstant: 44),

            dobField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 14),
            dobField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            dobField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            dobField.heightAnchor.constraint(equalToConstant: 44),

            passwordField.topAnchor.constraint(equalTo: dobField.bottomAnchor, constant: 14),
            passwordField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            passwordField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            passwordField.heightAnchor.constraint(equalToConstant: 44),

            repeatPasswordField.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 14),
            repeatPasswordField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            repeatPasswordField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            repeatPasswordField.heightAnchor.constraint(equalToConstant: 44),

            registerButton.topAnchor.constraint(equalTo: repeatPasswordField.bottomAnchor, constant: 26),
            registerButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            registerButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),

            loginLinkButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 12),
            loginLinkButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),

            activity.centerXAnchor.constraint(equalTo: registerButton.centerXAnchor),
            activity.centerYAnchor.constraint(equalTo: registerButton.centerYAnchor)
        ])
    }

    func setupDOBPicker() {
        dobField.inputView = dobPicker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didSelectDOB))
        toolbar.items = [doneBtn]
        dobField.inputAccessoryView = toolbar
        dobField.addTarget(self, action: #selector(datePickerTapped), for: .editingDidBegin)
    }

    @objc func didSelectDOB() {
        let f = DateFormatter()
        f.dateStyle = .medium
        dobField.text = f.string(from: dobPicker.date)
        dobField.resignFirstResponder()
    }
    @objc func datePickerTapped() { }

    func setupBinding() {
        presenter.registerResultPublisher
            .receive(on: RunLoop.main)
            .sink { _ in /* UI reaction handled by presenter via showAlert */ }
            .store(in: &cancellables)

        presenter.errorPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] err in
                guard let err, let self else { return }
                self.showAlert(title: "Registration Failed", message: err, onOK: {})
            }
            .store(in: &cancellables)
    }

    func setupActions() {
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        loginLinkButton.addTarget(self, action: #selector(didTapLoginLink), for: .touchUpInside)
    }

    @objc func didTapRegister() {
        presenter.onTapRegister(
            username: (usernameField.text ?? ""),
            email: (emailField.text ?? ""),
            dob: dobPicker.date,
            password: (passwordField.text ?? ""),
            repeatPassword: (repeatPasswordField.text ?? "")
        )
    }

    @objc func didTapLoginLink() {
        presenter.onTapLoginLink()
    }
}
