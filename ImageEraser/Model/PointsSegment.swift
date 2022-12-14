//
//  PointsSegment.swift
//  ImageEraser
//
//  Created by Christopher White on 04/09/2022.
//

import Foundation
import CoreGraphics

struct PointsSegment: Equatable, Identifiable {
    var id = UUID()
    var configuration: SegmentConfiguration

    var rectPoints: [CGPoint]
    var scaledPoints: [CGPoint]
}
