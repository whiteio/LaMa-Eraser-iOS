//
//  ImageMaskingView.swift
//  ImageEraser
//
//  Created by Christopher White on 03/09/2022.
//

import SwiftUI

struct ImageMaskingView: View {
    var selectedPhotoData: Data
    @Binding var points: [CGPoint]
    @Binding var previousPointsSegments: [[CGPoint]]
    @Binding var brushSize: Double

    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                points.append(value.location)
            }
            .onEnded { _ in
                previousPointsSegments.append(points)
                points = []
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
        }
    }
}
