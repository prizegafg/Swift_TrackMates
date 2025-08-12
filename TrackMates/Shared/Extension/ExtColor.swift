//
//  ExtColor.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 12/08/25.
//

import UIKit

// MARK: - UIColor + Hex helpers
extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255.0
        let g = CGFloat((hex >>  8) & 0xFF) / 255.0
        let b = CGFloat( hex        & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }

    convenience init(hex string: String) {
        var s = string.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s.hasPrefix("#") { s.removeFirst() }

        func component(_ start: Int, _ length: Int) -> CGFloat {
            let startIdx = s.index(s.startIndex, offsetBy: start)
            let endIdx   = s.index(startIdx, offsetBy: length)
            let sub = String(s[startIdx..<endIdx])
            let full = (length == 1) ? sub + sub : sub
            return CGFloat(Int(full, radix: 16) ?? 0) / 255.0
        }

        switch s.count {
        case 3: // RGB (4-bit)
            self.init(red: component(0,1), green: component(1,1), blue: component(2,1), alpha: 1)
        case 4: // RGBA (4-bit)
            self.init(red: component(0,1), green: component(1,1), blue: component(2,1), alpha: component(3,1))
        case 6: // RRGGBB
            self.init(red: component(0,2), green: component(2,2), blue: component(4,2), alpha: 1)
        case 8: // RRGGBBAA
            self.init(red: component(0,2), green: component(2,2), blue: component(4,2), alpha: component(6,2))
        default:
            self.init(white: 0.5, alpha: 1)
        }
    }

    static func dynamicHex(light: Int, dark: Int? = nil) -> UIColor {
        UIColor { trait in
            let hex = (trait.userInterfaceStyle == .dark) ? (dark ?? light) : light
            return UIColor(hex: hex)
        }
    }

    static func dynamicHex(light: String, dark: String? = nil) -> UIColor {
        UIColor { trait in
            let code = (trait.userInterfaceStyle == .dark) ? (dark ?? light) : light
            return UIColor(hex: code)
        }
    }
}

// MARK: - Color Token
extension UIColor {
    // Brand / Accent
    static let tmAccent          = UIColor(hex: 0x22C55E)
    static let tmTint            = UIColor(hex: "#3B82F6")                

    // Surfaces / Backgrounds
    static let tmBackground      = UIColor.systemBackground
    static let tmCardBackground  = UIColor.secondarySystemBackground
    static let tmFieldBackground = UIColor.dynamicHex(light: 0xF7F7F7, dark: 0x1F1F1F)

    // Text
    static let tmLabelPrimary    = UIColor.label
    static let tmLabelSecondary  = UIColor.secondaryLabel
    static let tmLabelInverse    = UIColor.white

    // Status
    static let tmSuccess         = UIColor(hex: 0x16A34A)
    static let tmWarning         = UIColor(hex: 0xF59E0B)
    static let tmError           = UIColor(hex: 0xEF4444)

    // Lines / Misc
    static let tmSeparator       = UIColor.separator
    static let tmBorder          = UIColor.dynamicHex(light: 0xD9D9D9, dark: 0x404040)
}

