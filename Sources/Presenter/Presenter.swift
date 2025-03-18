//
//  Presenter.swift
//  Presenter
//
//  Created by chen on 2025/3/18.
//

import SwiftUI

public struct Presenter<Content, Item>: UIViewRepresentable where Content: View {
    @Binding private var item: Item?
    private let presentationStyle: UIModalPresentationStyle
    private let transitionStyle: UIModalTransitionStyle
    private let popoverArrowDirections: UIPopoverArrowDirection
    private let shouldDismiss: Bool
    private let onDismiss: (() -> Void)?
    @ViewBuilder private let content: (Item) -> Content
    
    public init(
        item: Binding<Item?>,
        presentationStyle: UIModalPresentationStyle = .automatic,
        transitionStyle: UIModalTransitionStyle = .coverVertical,
        popoverArrowDirections: UIPopoverArrowDirection = .any,
        shouldDismiss: Bool,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self._item = item
        self.presentationStyle = presentationStyle
        self.transitionStyle = transitionStyle
        self.popoverArrowDirections = popoverArrowDirections
        self.shouldDismiss = shouldDismiss
        self.onDismiss = onDismiss
        self.content = content
    }
    
    public func makeCoordinator() -> Coordinator {
        .init(self)
    }
    
    public func makeUIView(context: Context) -> UIView {
        context.coordinator.dummyView
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.parent = self
    }
    
    public static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.dismiss()
    }
}

extension Presenter {
    public class Coordinator: NSObject, UIPopoverPresentationControllerDelegate {
        private weak var presentedViewController: UIHostingController<AnyView>?
        
        fileprivate var parent: Presenter<Content, Item> {
            didSet {
                updateState(from: oldValue.item, to: parent.item)
            }
        }
        
        let dummyView = UIView()
        
        init(_ parent: Presenter<Content, Item>) {
            self.parent = parent
            self.dummyView.backgroundColor = .clear
        }
        
        private func makeContentView(item: Item) -> AnyView {
            let dismissAction = DismissPresenterAction { [weak self] in
                self?.parent.item = nil
            }
            
            return AnyView(
                parent
                    .content(item)
                    .environment(\.dismissPresenter, dismissAction)
                    .onDisappear(perform: { [weak self] in
                        guard let self else {
                            return
                        }
                        
                        parent.item = nil
                        parent.onDismiss?()
                    })
            )
        }
        
        private func updateState(from old: Item?, to new: Item?) {
            if let new {
                if old == nil {
                    present(item: new)
                } else {
                    update(item: new)
                }
            } else if old != nil {
                dismiss()
            }
        }
        
        private func present(item: Item) {
            guard presentedViewController == nil, let presentingViewController = dummyView.parentViewController else {
                return
            }
            
            if let alreadyPresented = presentingViewController.presentedViewController {
                alreadyPresented.dismiss(animated: true)
            }
            
            let presentedViewController = UIHostingController(rootView: makeContentView(item: item))
            presentedViewController.view.backgroundColor = .clear
            presentedViewController.modalPresentationStyle = parent.presentationStyle
            presentedViewController.modalTransitionStyle = parent.transitionStyle
            presentedViewController.presentationController?.delegate = self
            
            if let popoverController = presentedViewController.popoverPresentationController {
                presentedViewController.preferredContentSize = presentedViewController.view.intrinsicContentSize
                
                popoverController.delegate = self
                popoverController.sourceView = dummyView
                popoverController.backgroundColor = .white
                popoverController.sourceRect = dummyView.bounds.insetBy(dx: 2, dy: 2)
                popoverController.permittedArrowDirections = parent.popoverArrowDirections
            }
            
            presentingViewController.present(presentedViewController, animated: true)
            
            self.presentedViewController = presentedViewController
        }
        
        private func update(item: Item) {
            presentedViewController?.rootView = makeContentView(item: item)
        }
        
        func dismiss() {
            guard let presentedViewController,
                  !presentedViewController.isBeingDismissed && presentedViewController.presentingViewController != nil
            else {
                return
            }
            
            presentedViewController.dismiss(animated: true)
        }
        
        // MARK: - UIAdaptivePresentationControllerDelegate
        
        public func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
            parent.shouldDismiss
        }
    }
}
