//
//  ExtUIWindow.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 10/08/25.
//

import UIKit

extension UIWindow {
    func setRoot(_ vc: UIViewController, animated: Bool) {
        guard animated else { rootViewController = vc; makeKeyAndVisible(); return }
        let snap = snapshotView(afterScreenUpdates: true) ?? UIView()
        snap.frame = bounds
        rootViewController = vc
        makeKeyAndVisible()
        addSubview(snap)
        UIView.animate(withDuration: 0.25, animations: {
            snap.alpha = 0
        }, completion: { _ in
            snap.removeFromSuperview()
        })
    }
}
