//
//  ImageEraserApp.swift
//  ImageEraser
//
//  Created by Christopher White on 30/08/2022.
//

import SwiftUI

@main
struct ImageEraserApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView(navigationStore: NavigationStore())
        .preferredColorScheme(.dark)
    }
  }
}
