//
//  ContentView.swift
//  ImageEraser
//
//  Created by Christopher White on 30/08/2022.
//

import SwiftUI

// MARK: - ContentView

struct ContentView: View {
    @Bindable var navigationStore: NavigationStore
    @State var hasAppeared = false
    @Namespace var namespace

    var body: some View {
        if hasAppeared {
            NavigationStack(path: $navigationStore.paths) {
                VStack {
                    ActionView()
                        .environment(navigationStore)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(MainScreenBackgroundView())
                .background(
                    Image("Spline")
                        .blur(radius: 50)
                        .offset(x: 200, y: 100))
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .editPhoto(let photoData):
                        let extractedExpr = EditViewModel()
                        EditView(photoData: photoData)
                            .environment(extractedExpr)
                            .environment(navigationStore)
                    }
                }
                .background(
                    Color("MainBackgroundColor")
                        .matchedGeometryEffect(id: "background", in: namespace))
                .ignoresSafeArea()
            }
        } else {
            SplashscreenPlaceholderView(namespace: namespace, hasAppeared: $hasAppeared)
        }
    }
}

// MARK: - ContentView_Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(navigationStore: NavigationStore())
            .preferredColorScheme(.dark)
    }
}
