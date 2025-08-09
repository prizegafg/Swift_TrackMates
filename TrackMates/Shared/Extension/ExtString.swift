//
//  ExtString.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 08/08/25.
//

import Foundation
import UIKit

extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
