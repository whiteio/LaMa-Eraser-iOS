//
//  PointsSegment.swift
//  ImageEraser
//
//  Created by Christopher White on 04/09/2022.
//

import Foundation
import CoreGraphics

struct PointsSegment: Equatable {
    var rectPoints: [CGPoint]
    var scaledPoints: [CGPoint]

    var imageSize: CGSize
    var rectSize: CGSize
}
