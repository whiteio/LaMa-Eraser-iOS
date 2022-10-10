//
//  PointsSegment_Array+Extras.swift
//  ImageEraser
//
//  Created by Christopher White on 04/09/2022.
//

import SwiftUI

extension Array where Element == PointsSegment {
    func scaledSegmentsToPath(imageState: ImagePresentationState) -> CGPath {
        var path = Path()

        for point in self {
            guard let firstPoint = point.scaledPoints.first else { return path.cgPath }

            path.move(to: firstPoint)

            path.move(to: firstPoint)
            for pointIndex in 1 ..< point.scaledPoints.count {
                path.addLine(to: point.scaledPoints[pointIndex])
            }
        }

        let mirror = CGAffineTransform(scaleX: 1,
                                       y: -1)
        let translate = CGAffineTransform(translationX: 0,
                                          y: imageState.imageSize.height)
        var concatenated = mirror.concatenating(translate)

        if let cgPath = path.cgPath.copy(using: &concatenated) {
            return cgPath
        } else {
            return path.cgPath
        }
    }
}
