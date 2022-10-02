//
//  View+Modifiers.swift
//  ImageEraser
//
//  Created by Christopher White on 02/10/2022.
//

import SwiftUI

public extension View {
    func alwaysPopover<Content>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View where Content: View {
        modifier(AlwaysPopoverModifier(isPresented: isPresented, contentBlock: content))
    }
}
