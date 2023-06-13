//
//  StateProtocols.swift
//  ImageEraser
//
//  Created by Christopher White on 10/10/2022.
//

import Foundation

// MARK: - HasModeState

protocol HasModeState {
  var mode: EditMode { get }
}

// MARK: - HasImagePresentationState

protocol HasImagePresentationState {
  var imagePresentationState: ImagePresentationState { get }
}

// MARK: - HasImageDataState

protocol HasImageDataState {
  var imageData: Data { get }
}

// MARK: - HasUndoState

protocol HasUndoState {
  var undoImageData: [Data] { get }
}

// MARK: - HasRedoState

protocol HasRedoState {
  var redoImageData: [Data] { get }
}

// MARK: - HasMaskPoints

protocol HasMaskPoints {
  var maskPoints: PointsSegment { get }
}

// MARK: - HasPreviousPoints

protocol HasPreviousPoints {
  var previousPoints: [PointsSegment] { get }
}

// MARK: - HasBrushSize

protocol HasBrushSize {
  var brushSize: Double { get }
}

// MARK: - HasBaseBrushSize

protocol HasBaseBrushSize {
  var baseBrushSize: Double { get }
}

// MARK: - HasScrollViewScale

protocol HasScrollViewScale {
  var scrollViewScale: CGFloat { get }
}

// MARK: - HasImageIsBeingProcessedState

protocol HasImageIsBeingProcessedState {
  var imageIsBeingProcessed: Bool { get }
}

// MARK: - HasSelectedEditControlIndex

protocol HasSelectedEditControlIndex {
  var selectedIndex: Int { get }
}
