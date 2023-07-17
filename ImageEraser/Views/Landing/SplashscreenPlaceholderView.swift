//
//  SplashScreenPlaceholderView.swift
//  ImageEraser
//
//  Created by Christopher White on 20/06/2023.
//

import Foundation
import SwiftUI

struct SplashscreenPlaceholderView: View {
    var namespace: Namespace.ID
    @Binding var hasAppeared: Bool

    var body: some View {
        Color("MainBackgroundColor")
            .matchedGeometryEffect(id: "background", in: namespace)
            .opacity(hasAppeared ? 0 : 1)
            .onAppear {
                withAnimation {
                    hasAppeared = true
                }
            }
    }
}
