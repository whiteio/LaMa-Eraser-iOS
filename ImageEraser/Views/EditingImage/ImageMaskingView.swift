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

  var drag: some Gesture {
    DragGesture(minimumDistance: 0)
      .onChanged { value in
        guard !state.imageIsBeingProcessed else { return }
        guard value.location.isInBounds(state.imagePresentationState.rectSize) else { return }

        state.maskPoints.rectPoints.append(value.location)

        let location = value.location
        let scaledX = location.x * widthScale
        let scaledY = location.y * heightScale
        let scaledPoint = CGPoint(x: scaledX, y: scaledY)
        state.maskPoints.scaledPoints.append(scaledPoint)
      }
      .onEnded { _ in
        guard !state.imageIsBeingProcessed else { return }

        state.imagePresentationState.imageSize = state.imageData.getSize()

        state.maskPoints.configuration = SegmentConfiguration(brushSize: state.brushSize * widthScale)

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
    if state.mode == .move {
      VStack(alignment: .trailing) {
        Image(uiImage: UIImage(data: state.imageData)!)
          .resizable()
          .scaledToFit()
          .clipped()
          .overlay(
            GestureMaskShape(
              previousPointsSegments: state.previousPoints,
              currentPointsSegment: state.maskPoints)
              .stroke(style: StrokeStyle(
                lineWidth: 10,
                lineCap: .round,
                lineJoin: .round))
              .foregroundColor(.blue))
          .clipped()
          .background(
            GeometryReader { geometry in
              Color.clear
                .onAppear {
                  state.imagePresentationState.rectSize = geometry.size
                }
            })
      }
    } else {
      VStack(alignment: .trailing) {
        Image(uiImage: UIImage(data: state.imageData)!)
          .resizable()
          .scaledToFit()
          .clipped()
          .gesture(drag)
          .overlay(
            GestureMaskShape(
              previousPointsSegments: state.previousPoints,
              currentPointsSegment: state.maskPoints)
              .stroke(style: StrokeStyle(
                lineWidth: state.brushSize,
                lineCap: .round,
                lineJoin: .round))
              .foregroundColor(.blue.opacity(0.4)))
          .clipped()
          .background(
            GeometryReader { geometry in
              Color.clear
                .onAppear {
                  state.imagePresentationState.rectSize = geometry.size
                }
            })
      }
    }
  }

  var heightScale: CGFloat {
    state.imageData.getSize().height / state.imagePresentationState.rectSize.height
  }

  var widthScale: CGFloat {
    state.imageData.getSize().width / state.imagePresentationState.rectSize.width
  }
}
