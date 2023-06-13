//
//  ContentViewController.swift
//  ImageEraser
//
//  Created by Christopher White on 02/10/2022.
//

import SwiftUI

class ContentViewController<V>: UIHostingController<V>, UIPopoverPresentationControllerDelegate where V: View {

  // MARK: Lifecycle

  init(rootView: V, isPresented: Binding<Bool>) {
    self.isPresented = isPresented
    super.init(rootView: rootView)
  }

  @available(*, unavailable)
  @MainActor @objc
  dynamic required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  var isPresented: Binding<Bool>

  override func viewDidLoad() {
    super.viewDidLoad()

    let size = sizeThatFits(in: UIView.layoutFittingExpandedSize)
    preferredContentSize = size
  }

  func adaptivePresentationStyle(
    for _: UIPresentationController,
    traitCollection _: UITraitCollection)
    -> UIModalPresentationStyle
  {
    .none
  }

  func presentationControllerDidDismiss(_: UIPresentationController) {
    isPresented.wrappedValue = false
  }
}
