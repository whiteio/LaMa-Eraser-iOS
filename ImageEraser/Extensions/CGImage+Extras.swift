//
//  CGImage+Extras.swift
//  ImageEraser
//
//  Created by Christopher White on 04/09/2022.
//

import Accelerate
import CoreGraphics
import UIKit

public extension CGImage {
    func createMaskFromLassoPath(_ path: CGPath, lineWidth: CGFloat) -> CGImage? {
        let width = self.width
        let height = self.height

        guard let bmContext = CGContext.ARGBBitmapContext(width: width, height: height, withAlpha: true) else {
            return nil
        }

        bmContext.setFillColor(UIColor.yellow.cgColor)
        bmContext.setStrokeColor(UIColor.yellow.cgColor)
        bmContext.setLineWidth(lineWidth)
        bmContext.setLineCap(.round)
        bmContext.setLineJoin(.round)
        bmContext.addPath(path)
        bmContext.drawPath(using: .fillStroke)

        let image = bmContext.makeImage()

        let result = image?.convertToGreyscale()

        return result
    }

    func createMaskFromPath(_ path: CGPath, lineWidth: CGFloat) -> CGImage? {
        let width = self.width
        let height = self.height

        guard let bmContext = CGContext.ARGBBitmapContext(width: width, height: height, withAlpha: true) else {
            return nil
        }

        bmContext.setStrokeColor(UIColor.yellow.cgColor)
        bmContext.setLineWidth(lineWidth)
        bmContext.setLineCap(.round)
        bmContext.setLineJoin(.round)
        bmContext.addPath(path)
        bmContext.drawPath(using: .stroke)

        let image = bmContext.makeImage()

        let result = image?.convertToGreyscale()

        return result
    }

    func convertToGreyscale() -> CGImage? {
        guard let format = vImage_CGImageFormat(
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            colorSpace: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue),
            renderingIntent: .defaultIntent
        ) else { return nil }

        guard
            var sourceBuffer = try? vImage_Buffer(cgImage: self,
                                                  format: format)
        else {
            return nil
        }

        let preBias: [Int16] = [0, 0, 0, 0]
        let postBias: Int32 = 0
        let divisor: Int32 = 0x1000
        let fDivisor = Float(divisor)

        let redCoefficient: Float = 1
        let greenCoefficient: Float = 1
        let blueCoefficient: Float = 1

        var coefficientsMatrix = [
            Int16(redCoefficient * fDivisor),
            Int16(greenCoefficient * fDivisor),
            Int16(blueCoefficient * fDivisor),
        ]

        // swiftlint:disable force_try
        var destinationBuffer = try! vImage_Buffer(width: width,
                                                   height: height,
                                                   bitsPerPixel: 8)

        vImageMatrixMultiply_ARGB8888ToPlanar8(&sourceBuffer,
                                               &destinationBuffer,
                                               &coefficientsMatrix,
                                               divisor,
                                               preBias,
                                               postBias,
                                               vImage_Flags(kvImageNoFlags))

        guard let monoFormat = vImage_CGImageFormat(
            bitsPerComponent: 8,
            bitsPerPixel: 8,
            colorSpace: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
            renderingIntent: .defaultIntent
        ) else {
            return nil
        }

        let result = try? destinationBuffer.createCGImage(format: monoFormat)
        return result
    }
}
