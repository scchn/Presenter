//
//  UIViewController+Ext.swift
//  Presenter
//
//  Created by chen on 2025/3/18.
//

import UIKit

extension UIViewController {
    var topMostViewController: UIViewController {
        if let presented = presentedViewController {
            presented.topMostViewController
        } else if let navigationController = self as? UINavigationController {
            navigationController.visibleViewController?.topMostViewController ?? self
        } else if let tabBarController = self as? UITabBarController {
            tabBarController.selectedViewController?.topMostViewController ?? self
        } else {
            self
        }
    }
}
