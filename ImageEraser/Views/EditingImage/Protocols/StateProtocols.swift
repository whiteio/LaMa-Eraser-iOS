//
//  StateProtocols.swift
//  ImageEraser
//
//  Created by Christopher White on 10/10/2022.
//

import Foundation

protocol HasModeState {
    var mode: EditMode { get }
}

protocol HasImagePresentationState {
    var imagePresentationState: ImagePresentationState { get }
}

protocol HasImageDataState {
    var imageData: Data { get }
}

protocol HasUndoState {
    var undoImageData: [Data] { get }
}

protocol HasRedoState {
    var redoImageData: [Data] { get }
}

protocol HasMaskPoints {
    var maskPoints: PointsSegment { get }
}

protocol HasPreviousPoints {
    var previousPoints: [PointsSegment] { get }
}

protocol HasBrushSize {
    var brushSize: Double { get }
}

protocol HasBaseBrushSize {
    var baseBrushSize: Double { get }
}

protocol HasScrollViewScale {
    var scrollViewScale: CGFloat { get }
}

protocol HasImageIsBeingProcessedState {
    var imageIsBeingProcessed: Bool { get }
}

protocol HasSelectedEditControlIndex {
    var selectedIndex: Int { get }
}
