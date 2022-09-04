//
//  ImageMaskingView.swift
//  ImageEraser
//
//  Created by Christopher White on 03/09/2022.
//

import SwiftUI
import CoreGraphics

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
                guard value.location.isInBounds(imageState.rectSize) else { return }

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
