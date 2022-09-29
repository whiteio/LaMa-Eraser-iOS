//
//  CGImage+Extras.swift
//  ImageEraser
//
//  Created by Christopher White on 04/09/2022.
//

import CoreGraphics
import UIKit

extension CGImage {

    public func addLassoPath(_ path: CGPath, lineWidth: CGFloat) -> CGImage? {
        let width = self.width
        let height = self.height

        guard let bmContext = CGContext.ARGBBitmapContext(width: width, height: height, withAlpha: true) else {
            return nil
        }

        bmContext.setFillColor(UIColor.white.cgColor)
        bmContext.setStrokeColor(UIColor.white.cgColor)
        bmContext.setLineWidth(lineWidth)
        bmContext.setLineCap(.round)
        bmContext.setLineJoin(.round)
        bmContext.addPath(path)
        bmContext.drawPath(using: .fillStroke)

        return bmContext.makeImage()
    }

    public func addPath(_ path: CGPath, lineWidth: CGFloat) -> CGImage? {
        let width = self.width
        let height = self.height

        guard let bmContext = CGContext.ARGBBitmapContext(width: width, height: height, withAlpha: true) else {
            return nil
        }

        bmContext.setStrokeColor(UIColor.white.cgColor)
        bmContext.setLineWidth(lineWidth)
        bmContext.setLineCap(.round)
        bmContext.setLineJoin(.round)
        bmContext.addPath(path)
        bmContext.drawPath(using: .stroke)

        return bmContext.makeImage()
    }
}
