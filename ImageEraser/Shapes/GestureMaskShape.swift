//
//  GestureMaskShape.swift
//  ImageEraser
//
//  Created by Christopher White on 04/09/2022.
//

import SwiftUI

struct GestureMaskShape: Shape {
    var previousPointsSegments: [PointsSegment]
    var currentPointsSegment: PointsSegment

    func path(in rect: CGRect) -> Path {
        var path = Path()

        for segment in previousPointsSegments {
            guard let firstPoint = segment.rectPoints.first else { return path }

            path.move(to: firstPoint)

            path.move(to: firstPoint)
            for pointIndex in 1..<segment.rectPoints.count {
                path.addLine(to: segment.rectPoints[pointIndex])
            }
        }

        guard let currentSegmentFirstPoint = currentPointsSegment.rectPoints.first else { return path }

        path.move(to: currentSegmentFirstPoint)
        for pointIndex in 1..<currentPointsSegment.rectPoints.count {
            path.addLine(to: currentPointsSegment.rectPoints[pointIndex])

        }
        return path
    }
}
