//
//  CGImage+Extras.swift
//  ImageEraser
//
//  Created by Christopher White on 04/09/2022.
//

import CoreGraphics
import UIKit
import Accelerate

extension CGImage {

    public func createMaskFromLassoPath(_ path: CGPath, lineWidth: CGFloat) -> CGImage? {
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

    public func createMaskFromPath(_ path: CGPath, lineWidth: CGFloat) -> CGImage? {
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

        let image = bmContext.makeImage()

        let result = image?.convertToGreyscale()

        return result
    }

    public func convertToGreyscale() -> CGImage? {
        let cgImage = self

        guard let format = vImage_CGImageFormat(
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            colorSpace: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue),
            renderingIntent: .defaultIntent) else { return nil }

        guard
            var sourceBuffer = try? vImage_Buffer(cgImage: cgImage,
                                                  format: format) else {
            return nil
        }

        let preBias: [Int16] = [0, 0, 0, 0]
        let postBias: Int32 = 0
        let divisor: Int32 = 0x1000
        let fDivisor = Float(divisor)

        let redCoefficient: Float = 0.2126
        let greenCoefficient: Float = 0.7152
        let blueCoefficient: Float = 0.0722

        var coefficientsMatrix = [
            Int16(redCoefficient * fDivisor),
            Int16(greenCoefficient * fDivisor),
            Int16(blueCoefficient * fDivisor)
        ]

        // swiftlint:disable force_try
        var destinationBuffer = try! vImage_Buffer(width: self.width,
                                              height: self.height,
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
            renderingIntent: .defaultIntent) else {
            return nil
        }

        let result = try? destinationBuffer.createCGImage(format: monoFormat)
        return result
    }
}
