//
//  View+Presenter.swift
//  Presenter
//
//  Created by chen on 2025/3/18.
//

import SwiftUI

extension View {
    @ViewBuilder public func presenter<Content>(
        isPresented: Binding<Bool>,
        presentationStyle: UIModalPresentationStyle = .automatic,
        transitionStyle: UIModalTransitionStyle = .coverVertical,
        popoverArrowDirections: UIPopoverArrowDirection = .any,
        shouldDismiss: Bool = true,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View
        where Content: View
    {
        let item = Binding<Void?> {
            isPresented.wrappedValue ? () : nil
        } set: { item in
            isPresented.wrappedValue = item != nil
        }
        
        background {
            Presenter(
                item: item,
                presentationStyle: presentationStyle,
                transitionStyle: transitionStyle,
                popoverArrowDirections: popoverArrowDirections,
                shouldDismiss: shouldDismiss,
                onDismiss: onDismiss,
                content: content
            )
        }
    }
    
    @ViewBuilder public func presenter<Content, Item>(
        item: Binding<Item?>,
        presentationStyle: UIModalPresentationStyle = .automatic,
        transitionStyle: UIModalTransitionStyle = .coverVertical,
        popoverArrowDirections: UIPopoverArrowDirection = .any,
        shouldDismiss: Bool = true,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View
        where Content: View
    {
        background {
            Presenter(
                item: item,
                presentationStyle: presentationStyle,
                transitionStyle: transitionStyle,
                popoverArrowDirections: popoverArrowDirections,
                shouldDismiss: shouldDismiss,
                onDismiss: onDismiss,
                content: content
            )
        }
    }
}

// MARK: - Popover

extension View {
    @ViewBuilder public func popoverPresenter<Content>(
        isPresented: Binding<Bool>,
        arrowDirections: UIPopoverArrowDirection = .any,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View
        where Content: View
    {
        presenter(
            isPresented: isPresented,
            presentationStyle: .popover,
            popoverArrowDirections: arrowDirections,
            onDismiss: onDismiss,
            content: content
        )
    }
    
    @ViewBuilder public func popoverPresenter<Item, Content>(
        item: Binding<Item?>,
        arrowDirections: UIPopoverArrowDirection = .any,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View
        where Content: View
    {
        presenter(
            item: item,
            presentationStyle: .popover,
            popoverArrowDirections: arrowDirections,
            onDismiss: onDismiss,
            content: content
        )
    }
}

#Preview("Presenter") {
    struct Modal: View {
        @Environment(\.dismissPresenter) private var dismiss
        var message: String
        
        var body: some View {
            VStack(spacing: 16) {
                Text(message)
                    .font(.title.bold())
                    .foregroundStyle(.red)
                
                Button("OK") {
                    dismiss()
                }
                .foregroundStyle(.white)
            }
            .padding(40)
            .background(.indigo)
            .clipShape(.rect(cornerRadius: 8))
        }
    }
    
    struct ContentView: View {
        @State private var presentedMessage: String?
        
        var body: some View {
            Color.teal
                .ignoresSafeArea()
                .overlay {
                    Button("Present") {
                        presentedMessage = "Error!"
                    }
                    .foregroundStyle(.white)
                }
                .presenter(
                    item: $presentedMessage,
                    presentationStyle: .overFullScreen
                ) { message in
                    Modal(message: message)
                }
        }
    }
    
    return ContentView()
}
