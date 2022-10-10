//
//  EditState.swift
//  ImageEraser
//
//  Created by Christopher White on 10/10/2022.
//

import SwiftUI

class EditState: ObservableObject {
    @Published var mode: Mode = .standardMask

    @Published var imageState: ImageState = .init(imageSize: .zero, rectSize: .zero)
    @Published var photoData: Data
    @Published var oldPhotoData: [Data] = []
    @Published var redoablePhotoData: [Data] = []
    @Published var maskPoints: PointsSegment = .init(configuration: SegmentConfiguration(brushSize: 30),
                                                     rectPoints: [],
                                                     scaledPoints: [])
    @Published var previousPointsSegments: [PointsSegment] = []
    @Published var currentBrushSize: Double = 30
    @Published var redoableSegments: [PointsSegment] = []
    @Published var baseBrushSize = 30.0
    @Published var scrollViewScale: CGFloat = 1.0
    @Published var imageIsBeingProcessed = false
    @Published var selectedIndex = 1

    init(photoData: Data) {
        self.photoData = photoData
    }
}
