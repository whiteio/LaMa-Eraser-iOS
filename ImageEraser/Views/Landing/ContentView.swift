//
//  ContentView.swift
//  ImageEraser
//
//  Created by Christopher White on 30/08/2022.
//

import RiveRuntime
import SwiftUI

// MARK: - ContentView

struct ContentView: View {
  @EnvironmentObject var navigationStore: NavigationStore

  var body: some View {
    NavigationStack(path: $navigationStore.paths) {
      VStack {
        SplashscreenContentView()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(
        RiveViewModel(fileName: "shapes").view()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .ignoresSafeArea()
          .blur(radius: 30)
          .blendMode(.hardLight))
      .background(
        Image("Spline")
          .blur(radius: 50)
          .offset(x: 200, y: 100))
      .navigationDestination(for: Route.self) { route in
        switch route {
        case .editPhoto(let photoData):
          let extractedExpr = EditInteractor()
          EditView(photoData: photoData)
            .environmentObject(extractedExpr)
        }
      }
      .toolbar(.hidden)
      .ignoresSafeArea()
    }
  }
}

// MARK: - SelectContentView

struct SelectContentView: View {
  let button = RiveViewModel(fileName: "button", autoPlay: false)

  var body: some View {
    VStack(alignment: .leading) {
      button.view()
        .frame(width: 236, height: 64)
        .background(
          Color.black
            .cornerRadius(30)
            .blur(radius: 10)
            .opacity(0.3)
            .offset(y: 10))
        .overlay(
          Label("Select a photo", systemImage: "photo.fill")
            .bold()
            .offset(x: 4, y: 4))
    }
  }
}

// MARK: - ContentView_Previews

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .preferredColorScheme(.dark)
  }
}

// MARK: - VisualEffectView

struct VisualEffectView: UIViewRepresentable {
  var effect: UIVisualEffect?
  func makeUIView(context _: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
  func updateUIView(
    _ uiView: UIVisualEffectView,
    context _: UIViewRepresentableContext<Self>)
  {
    uiView.effect = effect
  }
}
