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

    // MARK: UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.95) // seragam dengan login card feel
        v.layer.cornerRadius = 24
        v.layer.masksToBounds = false
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.08
        v.layer.shadowRadius = 16
        v.layer.shadowOffset = CGSize(width: 0, height: 8)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Registration"
        lbl.font = .systemFont(ofSize: 24, weight: .bold)
        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Create your Track Mates account to start your run or ride."
        lbl.font = .systemFont(ofSize: 14, weight: .regular)
        lbl.textColor = .darkGray
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let usernameField = RegisterView.makeField(placeholder: "Username")
    private let emailField    = RegisterView.makeField(placeholder: "Email", keyboard: .emailAddress)
    private let dobField      = RegisterView.makeField(placeholder: "Date of Birth")
    private let passwordField = RegisterView.makeField(placeholder: "Password", secure: true)
    private let repeatPasswordField = RegisterView.makeField(placeholder: "Repeat Password", secure: true)
    private lazy var showPassBtn: UIButton = RegisterView.makeEyeButton()
    private lazy var showRepeatPassBtn: UIButton = RegisterView.makeEyeButton()


    private let registerButton = RegisterView.makeButton(title: "Registration")
    private let loginLinkButton = RegisterView.makeLinkButton("Already Have Account? Login")

    private let activity = UIActivityIndicatorView(style: .medium)

    // Date Picker
    private let dobPicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.maximumDate = Date()
        if #available(iOS 13.4, *) { dp.preferredDatePickerStyle = .wheels }
        return dp
    }()

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setupDOBPicker()
        setupBinding()
        setupActions()
        setupKeyboardDismiss()
        presenter.attach(view: self)
    }
}

// MARK: - View Protocol
extension RegisterView: RegisterViewProtocol {
    var vc: UIViewController { self }

    func showAlert(title: String, message: String, onOK: @escaping () -> Void) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default) { _ in onOK() })
        present(a, animated: true)
    }

    func setLoading(_ loading: Bool) {
        if loading { activity.startAnimating() } else { activity.stopAnimating() }
        view.isUserInteractionEnabled = !loading // samakan pola dengan Login
        registerButton.alpha = loading ? 0.7 : 1
        loginLinkButton.alpha = loading ? 0.7 : 1
    }
}

// MARK: - UI Builders
private extension RegisterView {
    // Bisa dibuat reusable
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

    static func makeLinkButton(_ title: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.systemGreen, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }
    
    static func makeEyeButton() -> UIButton {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        btn.tintColor = .secondaryLabel
        btn.frame = CGRect(x: 0, y: 0, width: 44, height: 44) // rightView pakai frame
        btn.accessibilityLabel = "Show or hide password"
        return btn
    }
}

// MARK: - Setup
private extension RegisterView {
    func setupUI() {
        view.backgroundColor = .systemBackground

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.delaysContentTouches = false
        scrollView.keyboardDismissMode = .interactive

        contentView.translatesAutoresizingMaskIntoConstraints = false

        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.hidesWhenStopped = true

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(cardView)
        [titleLabel, subtitleLabel,
         usernameField, emailField, dobField,
         passwordField, repeatPasswordField,
         registerButton, loginLinkButton, activity]
            .forEach { cardView.addSubview($0) }
        
        passwordField.rightView = showPassBtn
        passwordField.rightViewMode = .always

        repeatPasswordField.rightView = showRepeatPassBtn
        repeatPasswordField.rightViewMode = .always

    }

    func setupLayout() {
        NSLayoutConstraint.activate([
            // ScrollView full screen
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Content guides
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            // Card
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 44),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),

            // Title & subtitle
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),

            // Fields
            usernameField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 28),
            usernameField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            usernameField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),

            emailField.topAnchor.constraint(equalTo: usernameField.bottomAnchor, constant: 14),
            emailField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            emailField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),

            dobField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 14),
            dobField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            dobField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),

            passwordField.topAnchor.constraint(equalTo: dobField.bottomAnchor, constant: 14),
            passwordField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            passwordField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),

            repeatPasswordField.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 14),
            repeatPasswordField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            repeatPasswordField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),

            // Buttons
            registerButton.topAnchor.constraint(equalTo: repeatPasswordField.bottomAnchor, constant: 22),
            registerButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            registerButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),

            loginLinkButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 14),
            loginLinkButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),

            // Activity on top of register button
            activity.centerXAnchor.constraint(equalTo: registerButton.centerXAnchor),
            activity.centerYAnchor.constraint(equalTo: registerButton.centerYAnchor),

            // 🔑 Important: close the bottom chain to fix tap/scroll
            loginLinkButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -18),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -44)
        ])
    }

    func setupDOBPicker() {
        dobField.inputView = dobPicker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didSelectDOB))
        toolbar.items = [doneBtn]
        dobField.inputAccessoryView = toolbar
    }

    func setupBinding() {
        presenter.registerResultPublisher
            .receive(on: RunLoop.main)
            .sink { _ in /* handled by presenter via showAlert */ }
            .store(in: &cancellables)

        presenter.errorPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] err in
                guard let self, let err else { return }
                self.showAlert(title: "Registration Failed", message: err, onOK: {})
            }
            .store(in: &cancellables)
    }

    func setupActions() {
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        loginLinkButton.addTarget(self, action: #selector(didTapLoginLink), for: .touchUpInside)
        showPassBtn.addTarget(self, action: #selector(togglePassword), for: .touchUpInside)
        showRepeatPassBtn.addTarget(self, action: #selector(toggleRepeatPassword), for: .touchUpInside)
    }

    func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false // jangan blokir tap ke field/tombol
        view.addGestureRecognizer(tap)
    }
    
    private func toggleSecureEntry(_ tf: UITextField, button: UIButton) {
        let wasFirstResponder = tf.isFirstResponder
        let existingText = tf.text

        tf.isSecureTextEntry.toggle()

        // Force refresh glyphs agar bullet ↔︎ plain sync
        if wasFirstResponder {
            tf.resignFirstResponder()
        }
        tf.text = nil
        tf.text = existingText
        if wasFirstResponder {
            tf.becomeFirstResponder()
        }

        let img = tf.isSecureTextEntry ? "eye.slash" : "eye"
        button.setImage(UIImage(systemName: img), for: .normal)
    }
}

// MARK: - Actions
private extension RegisterView {
    @objc func didSelectDOB() {
        let f = DateFormatter()
        f.dateStyle = .medium
        dobField.text = f.string(from: dobPicker.date)
        dobField.resignFirstResponder()
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

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func togglePassword() {
        toggleSecureEntry(passwordField, button: showPassBtn)
    }

    @objc func toggleRepeatPassword() {
        toggleSecureEntry(repeatPasswordField, button: showRepeatPassBtn)
    }
}
