//
//  ImageMaskingView.swift
//  ImageEraser
//
//  Created by Christopher White on 03/09/2022.
//

import CoreGraphics
import SwiftUI

struct ImageMaskingView: View {
    @ObservedObject var state: EditState
    var selectedPhotoData: Data
    @Binding var brushSize: Double
    @Binding var imageIsProcessing: Bool
    @Binding var mode: EditMode
    @State var imageSize: CGSize
    @Binding var imageState: ImagePresentationState

    init(editState: EditState,
         imageState: Binding<ImagePresentationState>,
         selectedPhotoData: Data,
         brushSize: Binding<Double>,
         imageIsProcessing: Binding<Bool>,
         mode: Binding<EditMode>)
    {
        state = editState
        _brushSize = brushSize
        self.selectedPhotoData = selectedPhotoData
        _imageSize = State(initialValue: selectedPhotoData.getSize())
        _imageState = imageState
        _imageIsProcessing = imageIsProcessing
        _mode = mode
    }

    var drag: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard !imageIsProcessing else { return }
                guard value.location.isInBounds(imageState.rectSize) else { return }

                state.maskPoints.rectPoints.append(value.location)

                let location = value.location
                let scaledX = location.x * widthScale
                let scaledY = location.y * heightScale
                let scaledPoint = CGPoint(x: scaledX, y: scaledY)
                state.maskPoints.scaledPoints.append(scaledPoint)
            }
            .onEnded { _ in
                guard !imageIsProcessing else { return }

                imageState.imageSize = imageSize

                state.maskPoints.configuration = SegmentConfiguration(brushSize: brushSize * widthScale)

                state.previousPoints.append(state.maskPoints)
                state.maskPoints.scaledPoints = []
                state.maskPoints.rectPoints = []
            }
    }

    var unwrappedDrag: DragGesture {
        guard let gesture = drag as? DragGesture else { return DragGesture() }

        return gesture
    }

    var body: some View {
        if mode == .move {
            VStack(alignment: .trailing) {
                Image(uiImage: UIImage(data: selectedPhotoData)!)
                    .resizable()
                    .scaledToFit()
                    .clipped()
                    .overlay(
                        GestureMaskShape(previousPointsSegments: state.previousPoints,
                                         currentPointsSegment: state.maskPoints)
                            .stroke(style: StrokeStyle(lineWidth: 10,
                                                       lineCap: .round,
                                                       lineJoin: .round))
                            .foregroundColor(.blue)
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
        } else {
            VStack(alignment: .trailing) {
                Image(uiImage: UIImage(data: selectedPhotoData)!)
                    .resizable()
                    .scaledToFit()
                    .clipped()
                    .gesture(drag)
                    .overlay(
                        GestureMaskShape(previousPointsSegments: state.previousPoints,
                                         currentPointsSegment: state.maskPoints)
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
    }

    var heightScale: CGFloat {
        imageSize.height / imageState.rectSize.height
    }

    var widthScale: CGFloat {
        imageSize.width / imageState.rectSize.width
    }
}
