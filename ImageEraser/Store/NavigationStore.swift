//
//  NavigationStore.swift
//  ImageEraser
//
//  Created by Christopher White on 04/09/2022.
//

import Foundation
import Observation
import SwiftUI

@Observable
class NavigationStore {
  var paths: [Route] = []

  func navigateToPath(_ route: Route) {
    paths.append(route)
  }

  func dismissView() {
    paths.removeLast()
  }
}
