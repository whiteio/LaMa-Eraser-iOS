//
//  View+Modifiers.swift
//  ImageEraser
//
//  Created by Christopher White on 02/10/2022.
//

import SwiftUI

extension View {
  public func alwaysPopover(
    isPresented: Binding<Bool>,
    @ViewBuilder content: @escaping () -> some View)
    -> some View
  {
    modifier(AlwaysPopoverModifier(isPresented: isPresented, contentBlock: content))
  }
}
