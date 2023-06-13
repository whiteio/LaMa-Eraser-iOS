//
//  CGContext+Extras.swift
//  ImageEraser
//
//  Created by Christopher White on 04/09/2022.
//

import CoreGraphics

extension CGContext {
  // MARK: - ARGB bitmap context
  public class func ARGBBitmapContext(width: Int, height: Int, withAlpha: Bool) -> CGContext? {
    let alphaInfo = withAlpha ? CGImageAlphaInfo.premultipliedFirst : CGImageAlphaInfo.noneSkipFirst
    let bmContext = CGContext(
      data: nil,
      width: width,
      height: height,
      bitsPerComponent: 8,
      bytesPerRow: width * ImagePixelConstants.numberOfComponentsPerARBGPixel,
      space: CGColorSpaceCreateDeviceRGB(),
      bitmapInfo: alphaInfo.rawValue)
    return bmContext
  }
}
