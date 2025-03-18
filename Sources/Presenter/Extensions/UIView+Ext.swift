//
//  UIView+Ext.swift
//  Presenter
//
//  Created by chen on 2025/3/18.
//

import UIKit

extension UIView {
    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        
        if let window = window {
            return window.rootViewController?.topMostViewController
        } else if
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.keyWindow
        {
            return window.rootViewController?.topMostViewController
        } else {
            return nil
        }
    }
}
