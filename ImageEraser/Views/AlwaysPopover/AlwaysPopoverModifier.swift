//
//  AlwaysPopoverModifier.swift
//  ImageEraser
//
//  Created by Christopher White on 02/10/2022.
//

import SwiftUI

struct AlwaysPopoverModifier<PopoverContent>: ViewModifier where PopoverContent: View {
    let isPresented: Binding<Bool>
    let contentBlock: () -> PopoverContent

    // Workaround for missing @StateObject in iOS 13.
    private struct Store {
        var anchorView = UIView()
    }

    @State private var store = Store()

    func body(content: Content) -> some View {
        if isPresented.wrappedValue {
            presentPopover()
        }

        return content
            .background(InternalAnchorView(uiView: store.anchorView))
    }

    private func presentPopover() {
        let contentController = ContentViewController(rootView: contentBlock(), isPresented: isPresented)
        contentController.modalPresentationStyle = .popover

        let view = store.anchorView
        guard let popover = contentController.popoverPresentationController else { return }
        popover.sourceView = view
        popover.sourceRect = view.bounds
        popover.delegate = contentController

        guard let sourceVC = view.closestVC() else { return }
        if let presentedVC = sourceVC.presentedViewController {
            presentedVC.dismiss(animated: true) {
                sourceVC.present(contentController, animated: true)
            }
        } else {
            sourceVC.present(contentController, animated: true)
        }
    }

    private struct InternalAnchorView: UIViewRepresentable {
        typealias UIViewType = UIView
        let uiView: UIView

        func makeUIView(context _: Self.Context) -> Self.UIViewType {
            uiView
        }

        func updateUIView(_: Self.UIViewType, context _: Self.Context) {}
    }
}
