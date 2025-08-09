//
//  RegisterRouter.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import UIKit

protocol RegisterRouterProtocol {
    func navigateToHome(from view: UIViewController, user: UserEntity)
}

final class RegisterRouter: RegisterRouterProtocol {
    func navigateToHome(from view: UIViewController, user: UserEntity) {
        // Navigate ke home
    }
}
