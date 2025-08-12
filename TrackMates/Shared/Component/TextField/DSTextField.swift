//
//  DSTextField.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 12/08/25.
//

import UIKit
import ObjectiveC

public final class FormTextField: UITextField {
    public convenience init(_ placeholder: String,
                            keyboard: UIKeyboardType = .default,
                            secure: Bool = false) {
        self.init(frame: .zero)
        self.placeholder = placeholder
        self.autocapitalizationType = .none
        self.keyboardType = keyboard
        self.isSecureTextEntry = secure
        self.borderStyle = .roundedRect
        self.backgroundColor = .tmFieldBackground
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: DesignSystem.Metric.fieldHeight).isActive = true
    }
}

enum DesignTextField {
    static func field(_ placeholder: String,
                      keyboard: UIKeyboardType = .default) -> UITextField {
        FormTextField(placeholder, keyboard: keyboard, secure: false)
    }

    static func secure(_ placeholder: String) -> UITextField {
        FormTextField(placeholder, keyboard: .default, secure: true)
    }

    /// Tambahkan tombol mata ke rightView + handle toggle (caret tidak loncat)
    @discardableResult
    static func addEyeToggle(to tf: UITextField) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        btn.tintColor = .secondaryLabel
        btn.frame = CGRect(x: 0, y: 0,
                           width: DesignSystem.Metric.touch,
                           height: DesignSystem.Metric.touch)
        btn.accessibilityLabel = "Show or hide password"

        if #available(iOS 14.0, *) {
            btn.addAction(UIAction { [weak tf, weak btn] _ in
                guard let tf = tf, let btn = btn else { return }
                toggleSecure(tf, with: btn)
            }, for: .touchUpInside)
        } else {
            // iOS 13 fallback: target = button sendiri, selector method di extension UIButton (lihat bawah)
            objc_setAssociatedObject(btn, &AssocKey.textField, tf, .OBJC_ASSOCIATION_ASSIGN)
            btn.addTarget(btn, action: #selector(UIButton.tm_toggleSecureAction(_:)), for: .touchUpInside)
        }

        tf.rightView = btn
        tf.rightViewMode = .always
        return btn
    }

    static func toggleSecure(_ textField: UITextField, with button: UIButton) {
        let wasFirstResponder = textField.isFirstResponder
        let snapshot = textField.text

        textField.isSecureTextEntry.toggle()

        // Fix caret jump di secureTextEntry
        if wasFirstResponder { textField.resignFirstResponder() }
        textField.text = nil
        textField.text = snapshot
        if wasFirstResponder { textField.becomeFirstResponder() }

        let symbol = textField.isSecureTextEntry ? "eye.slash" : "eye"
        button.setImage(UIImage(systemName: symbol), for: .normal)
    }
}

// Back-compat (opsional). Perhatikan disambiguasi agar tidak tabrakan dengan nama fungsi `secure(_:)`.
extension DesignTextField {
    static func makeField(placeholder: String,
                          keyboard: UIKeyboardType = .default,
                          secure: Bool = false) -> UITextField {
        secure ? DesignTextField.secure(placeholder) : field(placeholder, keyboard: keyboard)
    }

    static func makeEyeButton() -> UIButton {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        btn.tintColor = .secondaryLabel
        btn.frame = CGRect(x: 0, y: 0,
                           width: DesignSystem.Metric.touch,
                           height: DesignSystem.Metric.touch)
        btn.accessibilityLabel = "Show or hide password"
        return btn
    }
}

// MARK: - iOS 13 fallback infra (tanpa retain cycle)
private enum AssocKey { static var textField: UInt8 = 0 }

private extension UIButton {
    @objc func tm_toggleSecureAction(_ sender: UIButton) {
        guard let tf = objc_getAssociatedObject(self, &AssocKey.textField) as? UITextField else { return }
        DesignTextField.toggleSecure(tf, with: self)
    }
}
