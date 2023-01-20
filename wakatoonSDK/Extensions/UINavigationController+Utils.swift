//
//  UINavigationController+Utils.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 19/12/22.
//

import Foundation
import UIKit


extension UINavigationController {
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
            popToViewController(vc, animated: animated)
        }
    }
    func containsViewController(ofKind kind: AnyClass) -> Bool {
        return self.viewControllers.contains(where: { $0.isKind(of: kind) })
    }
    func popBack(_ count: Int, animated: Bool = true) {
        let viewControllers: [UIViewController] = self.viewControllers
        guard viewControllers.count < count else {
            self.popToViewController(viewControllers[viewControllers.count - count], animated: animated)
            return
        }
    }
}
