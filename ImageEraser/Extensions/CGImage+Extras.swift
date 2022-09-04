//
//  CGImage+Extras.swift
//  ImageEraser
//
//  Created by Christopher White on 04/09/2022.
//

import CoreGraphics
import UIKit

extension CGImage {
    // NOTE: - This is an example of how to do lasso path
    //    public func addPath(_ path: CGPath, lineWidth: CGFloat) -> CGImage? {
    //        let width = self.width
    //        let height = self.height
    //
    //        guard let bmContext = CGContext.ARGBBitmapContext(width: width, height: height, withAlpha: true) else {
    //            return nil
    //        }
    //
    //        let rectangle = CGRect(x: 0, y: 0, width: width, height: height)
    //
    //        bmContext.setFillColor(UIColor.red.cgColor)
    //        bmContext.setStrokeColor(UIColor.yellow.cgColor)
    //        bmContext.setLineWidth(lineWidth)
    //
    //        //        bmContext.addRect(rectangle)
    //
    //        bmContext.addPath(path)
    //        bmContext.drawPath(using: .fillStroke)
    //        //        bmContext.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
    //
    //        return bmContext.makeImage()
    //    }

    public func addPath(_ path: CGPath, lineWidth: CGFloat) -> CGImage? {
        let width = self.width
        let height = self.height

        guard let bmContext = CGContext.ARGBBitmapContext(width: width, height: height, withAlpha: true) else {
            return nil
        }

        bmContext.setFillColor(UIColor.red.cgColor)
        bmContext.setStrokeColor(UIColor.yellow.cgColor)
        bmContext.setLineWidth(lineWidth)
        bmContext.addPath(path)
        bmContext.drawPath(using: .fillStroke)
        //        bmContext.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))

        return bmContext.makeImage()
    }
}
