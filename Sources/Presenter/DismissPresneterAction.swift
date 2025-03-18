//
//  DismissPresneterAction.swift
//  Presenter
//
//  Created by chen on 2025/3/18.
//

import SwiftUI

public struct DismissPresenterAction: @unchecked Sendable {
    var onDismiss: (() -> Void)?
    
    public func callAsFunction() {
        onDismiss?()
    }
}

private struct DismissPresenterEnvironmentKey: EnvironmentKey {
    static let defaultValue: DismissPresenterAction = .init(onDismiss: nil)
}

extension EnvironmentValues {
    public var dismissPresenter: DismissPresenterAction {
        get { self[DismissPresenterEnvironmentKey.self] }
        set { self[DismissPresenterEnvironmentKey.self] = newValue }
    }
}

