//
//  RegisterView.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import UIKit
import Combine

// MARK: - RegisterView
final class RegisterView: UIViewController {
    var presenter: RegisterPresenterProtocol!
    private var cancellables = Set<AnyCancellable>()

    // MARK: UI Metrics
    private enum UI {
        static let cardTop: CGFloat   = 44
        static let cardSide: CGFloat  = 28
        static let hInset: CGFloat    = 18
        static let vTitle: CGFloat    = 32
        static let vBig: CGFloat      = 28
        static let v: CGFloat         = 14
        static let vBottom: CGFloat   = 18
        static let vBtnTop: CGFloat   = 22
    }

    // MARK: Views
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.alwaysBounceVertical = true
        sv.delaysContentTouches = false
        sv.keyboardDismissMode = .interactive
        return sv
    }()
    private let contentView = UIView()

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.95)
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
        lbl.textColor = .tmLabelPrimary
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Create your Track Mates account to start your run or ride."
        lbl.font = .systemFont(ofSize: 14, weight: .regular)
        lbl.textColor = .tmLabelSecondary
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // Fields 
    private let usernameField        = DesignTextField.field("Username")
    private let emailField           = DesignTextField.field("Email", keyboard: .emailAddress)
    private let dobField             = DesignTextField.field("Date of Birth")
    private let passwordField        = DesignTextField.secure("Password")
    private let repeatPasswordField  = DesignTextField.secure("Repeat Password")

    // Toggle eye buttons
    private var showPassBtn: UIButton!
    private var showRepeatPassBtn: UIButton!

    // Buttons
    private let registerButton = DesignButton.primary("Registration")
    private let loginLinkButton = DesignButton.link("Already Have Account? Login")

    private let activity: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(style: .medium)
        a.translatesAutoresizingMaskIntoConstraints = false
        a.hidesWhenStopped = true
        return a
    }()

    // Date picker
    private let dobPicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.maximumDate = Date()
        if #available(iOS 13.4, *) { dp.preferredDatePickerStyle = .wheels }
        return dp
    }()
    private lazy var dobFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        layoutUI()
        setupDOBPicker()
        bindPresenter()
        bindActions()
        enableKeyboardDismiss()
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
        loading ? activity.startAnimating() : activity.stopAnimating()
        view.isUserInteractionEnabled = !loading
        registerButton.alpha = loading ? 0.7 : 1
        loginLinkButton.alpha = loading ? 0.7 : 1
    }
}

// MARK: - UI setup
private extension RegisterView {
    func buildUI() {
        view.backgroundColor = .systemBackground

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(cardView)

        [titleLabel, subtitleLabel,
         usernameField, emailField, dobField,
         passwordField, repeatPasswordField,
         registerButton, loginLinkButton, activity]
            .forEach { cardView.addSubview($0) }

        // Eye toggles via reusable helper
        showPassBtn = DesignTextField.addEyeToggle(to: passwordField)
        showRepeatPassBtn = DesignTextField.addEyeToggle(to: repeatPasswordField)
    }

    func layoutUI() {
        NSLayoutConstraint.activate([
            // scroll container
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            // card
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: UI.cardTop),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UI.cardSide),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -UI.cardSide),

            // title & subtitle
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: UI.vTitle),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: UI.hInset),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -UI.hInset),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: UI.hInset),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -UI.hInset),

            // fields
            usernameField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: UI.vBig),
            usernameField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: UI.hInset),
            usernameField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -UI.hInset),

            emailField.topAnchor.constraint(equalTo: usernameField.bottomAnchor, constant: UI.v),
            emailField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: UI.hInset),
            emailField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -UI.hInset),

            dobField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: UI.v),
            dobField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: UI.hInset),
            dobField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -UI.hInset),

            passwordField.topAnchor.constraint(equalTo: dobField.bottomAnchor, constant: UI.v),
            passwordField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: UI.hInset),
            passwordField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -UI.hInset),

            repeatPasswordField.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: UI.v),
            repeatPasswordField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: UI.hInset),
            repeatPasswordField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -UI.hInset),

            // buttons
            registerButton.topAnchor.constraint(equalTo: repeatPasswordField.bottomAnchor, constant: UI.vBtnTop),
            registerButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: UI.hInset),
            registerButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -UI.hInset),

            loginLinkButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 14),
            loginLinkButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),

            // activity
            activity.centerXAnchor.constraint(equalTo: registerButton.centerXAnchor),
            activity.centerYAnchor.constraint(equalTo: registerButton.centerYAnchor),

            // bottom
            loginLinkButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -UI.vBottom),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -UI.cardTop)
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
}

// MARK: - Bindings & Actions
private extension RegisterView {
    func bindPresenter() {
        presenter.registerResultPublisher
            .receive(on: RunLoop.main)
            .sink { _ in /* presenter will route via showAlert callback */ }
            .store(in: &cancellables)

        presenter.errorPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] err in
                guard let self, let err else { return }
                self.showAlert(title: "Registration Failed", message: err, onOK: {})
            }
            .store(in: &cancellables)
    }

    func bindActions() {
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        loginLinkButton.addTarget(self, action: #selector(didTapLoginLink), for: .touchUpInside)
        // eye buttons sudah di-handle oleh DesignTextField.addEyeToggle(to:)
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

    @objc func didSelectDOB() {
        dobField.text = dobFormatter.string(from: dobPicker.date)
        dobField.resignFirstResponder()
    }
}

// MARK: - Keyboard dismiss
private extension RegisterView {
    func enableKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
