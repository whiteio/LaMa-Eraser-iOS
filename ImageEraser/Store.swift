//
//  Store.swift
//  ImageEraser
//
//  Created by Christopher White on 04/09/2022.
//

import Foundation
import SwiftUI

class Store: ObservableObject {
    @Published var paths: [Route] = []

    func navigateToPath(_ route: Route) {
        paths.append(route)
    }
}
