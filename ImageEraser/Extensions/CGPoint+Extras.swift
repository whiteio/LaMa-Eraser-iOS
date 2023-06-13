//
//  CGPoint+Extras.swift
//  ImageEraser
//
//  Created by Christopher White on 04/09/2022.
//

import Foundation

extension CGPoint {
  func isInBounds(_ bounds: CGSize) -> Bool {
    x >= 0 &&
      y >= 0 &&
      x <= bounds.width &&
      y <= bounds.height
  }
}
