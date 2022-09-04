//
//  ImageMaskingView.swift
//  ImageEraser
//
//  Created by Christopher White on 03/09/2022.
//

import SwiftUI
import CoreGraphics
import Accelerate

struct ImageMaskingView: View {
    var selectedPhotoData: Data
    @Binding var points: PointsSegment
    @Binding var previousPointsSegments: [PointsSegment]
    @Binding var brushSize: Double
    @Binding var redoableSegments: [PointsSegment]

    init(imageState: Binding<ImageState>,
         selectedPhotoData: Data,
         points: Binding<PointsSegment>,
         previousPointsSegments: Binding<[PointsSegment]>,
         brushSize: Binding<Double>,
         redoableSegments: Binding<[PointsSegment]>) {
        self._points = points
        self._previousPointsSegments = previousPointsSegments
        self._brushSize = brushSize
        self._redoableSegments = redoableSegments
        self.selectedPhotoData = selectedPhotoData
        self._imageSize = State(initialValue: selectedPhotoData.getSize())
        self._imageState = imageState
    }

    @State var imageSize: CGSize
    @Binding var imageState: ImageState

    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                guard value.location.y >= 0,
                      value.location.y <= imageState.rectSize.height,
                      value.location.x >= 0,
                      value.location.x <= imageState.rectSize.width else { return }

                points.rectPoints.append(value.location)

                let location = value.location
                let scaledX = location.x * widthScale
                let scaledY = location.y * heightScale
                let scaledPoint = CGPoint(x: scaledX, y: scaledY)
                points.scaledPoints.append(scaledPoint)
            }
            .onEnded { _ in
                imageState.imageSize = imageSize

                points.configuration = SegmentConfiguration(brushSize: brushSize)

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
                        GestureMaskShape(previousPointsSegments: previousPointsSegments,
                                         currentPointsSegment: points)
                            .stroke(style: StrokeStyle(lineWidth: brushSize,
                                                       lineCap: .round,
                                                       lineJoin: .round))
                            .foregroundColor(.blue.opacity(0.4))
                    )
                    .clipped()
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    imageState.rectSize = geometry.size
                                }
                        }
                    )
        }
    }

    var heightScale: CGFloat {
        imageSize.height / imageState.rectSize.height
    }

    var widthScale: CGFloat {
        imageSize.width / imageState.rectSize.width
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
