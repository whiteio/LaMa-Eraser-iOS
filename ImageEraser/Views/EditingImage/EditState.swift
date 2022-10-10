//
//  EditState.swift
//  ImageEraser
//
//  Created by Christopher White on 10/10/2022.
//

import SwiftUI

typealias StateAbilities = HasModeState & HasImagePresentationState & HasImageDataState
    & HasUndoState & HasRedoState & HasMaskPoints & HasPreviousPoints & HasBrushSize
    & HasBaseBrushSize & HasScrollViewScale & HasImageIsBeingProcessedState
    & HasSelectedEditControlIndex

class EditState: ObservableObject, StateAbilities {
    @Published var mode: EditMode = .standardMask

    @Published var imagePresentationState: ImagePresentationState = .init(imageSize: .zero, rectSize: .zero)
    @Published var imageData: Data
    @Published var undoImageData: [Data] = []
    @Published var redoImageData: [Data] = []
    @Published var maskPoints: PointsSegment = .init(configuration: SegmentConfiguration(brushSize: 30),
                                                     rectPoints: [],
                                                     scaledPoints: [])
    @Published var previousPoints: [PointsSegment] = []
    @Published var brushSize: Double = 30
    @Published var baseBrushSize = 30.0
    @Published var scrollViewScale: CGFloat = 1.0
    @Published var imageIsBeingProcessed = false
    @Published var selectedIndex = 1

    init(photoData: Data) {
        imageData = photoData
    }
}
