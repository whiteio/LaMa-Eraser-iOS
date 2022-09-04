//
//  ImageMaskingView.swift
//  ImageEraser
//
//  Created by Christopher White on 03/09/2022.
//

import SwiftUI
import CoreGraphics
import Accelerate

struct PointsSegment: Equatable {
    var rectPoints: [CGPoint]
    var scaledPoints: [CGPoint]
}

struct ImageMaskingView: View {
    var selectedPhotoData: Data
    @Binding var points: PointsSegment
    @Binding var previousPointsSegments: [PointsSegment]
    @Binding var brushSize: Double
    @Binding var redoableSegments: [PointsSegment]

    init(selectedPhotoData: Data, points: Binding<PointsSegment>,
         previousPointsSegments: Binding<[PointsSegment]>,
         brushSize: Binding<Double>,
         redoableSegments: Binding<[PointsSegment]>) {
        self._points = points
        self._previousPointsSegments = previousPointsSegments
        self._brushSize = brushSize
        self._redoableSegments = redoableSegments
        self.selectedPhotoData = selectedPhotoData
        self._imageSize = State(initialValue: selectedPhotoData.getSize())
    }

    @State var imageSize: CGSize
    @State var imageViewSize: CGSize = CGSize(width: 0, height: 0)

    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                guard value.location.y >= 0,
                      value.location.y <= imageViewSize.height,
                      value.location.x >= 0,
                      value.location.x <= imageViewSize.width else { return }
                
                points.rectPoints.append(value.location)

                let location = value.location
                let heightScale = imageSize.height / imageViewSize.height
                let widthScale = imageSize.width / imageViewSize.width
                let scaledX = location.x * widthScale
                let scaledY = location.y * heightScale
                let scaledPoint = CGPoint(x: scaledX, y: scaledY)
                points.scaledPoints.append(scaledPoint)
                print("====================")
                print("Image size: \(imageSize)")
                print("X: \(location.x), scaled X: \(scaledX)")
                print("Y: \(location.y), scaled Y: \(scaledY)")
            }
            .onEnded { _ in
                previousPointsSegments.append(points)
                redoableSegments.removeAll()
                points.scaledPoints = []
                points.rectPoints = []
            }
    }

    var body: some View {
        VStack(alignment: .trailing) {
                Image(uiImage: UIImage(data: selectedPhotoData)!)
                    .resizable()
                    .scaledToFit()
                    .clipped()
                    .gesture(drag)
                    .overlay(
                        DrawShape(previousPointsSegments: previousPointsSegments, currentPointsSegment: points)
                            .stroke(style: StrokeStyle(lineWidth: brushSize, lineCap: .round, lineJoin: .round))
                            .foregroundColor(.blue.opacity(0.4))
                    )
                    .clipped()
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    imageViewSize = geometry.size
                                }
                        }
                    )
        }
    }
}

extension Data {
    func getSize() -> CGSize {
        let image = UIImage(data: self)
        if let cgImage = image?.cgImage {
            return CGSize(width: cgImage.width, height: cgImage.height)
        }

        return CGSize(width: 0, height: 0)
    }
}

extension CGImage {
    public func addPath(_ path: Path) -> CGImage? {
        let width = self.width
        let height = self.height

        guard let bmContext = CGContext.ARGBBitmapContext(width: width, height: height, withAlpha: true) else {
            return nil
        }

        let rectangle = CGRect(x: 0, y: 0, width: width, height: height)

        bmContext.setFillColor(UIColor.red.cgColor)
        bmContext.setStrokeColor(UIColor.yellow.cgColor)
        bmContext.setLineWidth(10)

//        bmContext.addRect(rectangle)

        bmContext.addPath(path.cgPath)
        bmContext.drawPath(using: .fillStroke)
//        bmContext.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))

        return bmContext.makeImage()
    }
}

// CGContext+Extensions.swift
// Copyright (c) 2016 Nyx0uf
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

struct ImgHelp {
    public static let numberOfComponentsPerARBGPixel = 4
    public static let numberOfComponentsPerRGBAPixel = 4
    public static let numberOfComponentsPerGrayPixel = 3
    public static let minPixelComponentValue = UInt8(0)
    public static let maxPixelComponentValue = UInt8(255)
}

public extension CGContext {
    // MARK: - ARGB bitmap context
    class func ARGBBitmapContext(width: Int, height: Int, withAlpha: Bool) -> CGContext? {
        let alphaInfo = withAlpha ? CGImageAlphaInfo.premultipliedFirst : CGImageAlphaInfo.noneSkipFirst
        let bmContext = CGContext(data: nil,
                                  width: width,
                                  height: height,
                                  bitsPerComponent: 8,
                                  bytesPerRow: width * ImgHelp.numberOfComponentsPerARBGPixel,
                                  space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: alphaInfo.rawValue)
        return bmContext
    }

    // MARK: - RGBA bitmap context
    class func RGBABitmapContext(width: Int, height: Int, withAlpha: Bool) -> CGContext? {
        let alphaInfo = withAlpha ? CGImageAlphaInfo.premultipliedLast : CGImageAlphaInfo.noneSkipLast
        let bmContext = CGContext(data: nil,
                                  width: width,
                                  height: height,
                                  bitsPerComponent: 8,
                                  bytesPerRow: width * ImgHelp.numberOfComponentsPerRGBAPixel,
                                  space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: alphaInfo.rawValue)
        return bmContext
    }

    // MARK: - Gray bitmap context
    class func grayBitmapContext(width: Int, height: Int) -> CGContext? {
        let bmContext = CGContext(data: nil,
                                  width: width,
                                  height: height,
                                  bitsPerComponent: 8,
                                  bytesPerRow: width * ImgHelp.numberOfComponentsPerGrayPixel,
                                  space: CGColorSpaceCreateDeviceGray(),
                                  bitmapInfo: CGImageAlphaInfo.none.rawValue)
        return bmContext
    }
}
