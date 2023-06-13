//
//  EditState.swift
//  ImageEraser
//
//  Created by Christopher White on 10/10/2022.
//

import Observation
import SwiftUI

typealias StateAbilities
  = HasModeState
  & HasImagePresentationState
  & HasImageDataState
  & HasUndoState
  & HasRedoState
  & HasMaskPoints
  & HasPreviousPoints
  & HasBrushSize
  & HasBaseBrushSize
  & HasScrollViewScale
  & HasImageIsBeingProcessedState
  & HasSelectedEditControlIndex

// MARK: - EditState

@Observable
class EditState: StateAbilities {

  // MARK: Lifecycle

  init(photoData: Data) {
    imageData = photoData
  }

  // MARK: Internal

  var mode: EditMode = .standardMask

  var imagePresentationState: ImagePresentationState = .init(imageSize: .zero, rectSize: .zero)
  var imageData: Data? = nil
  var undoImageData: [Data] = []
  var redoImageData: [Data] = []
  var maskPoints: PointsSegment = .init(
    configuration: SegmentConfiguration(brushSize: 30),
    rectPoints: [],
    scaledPoints: [])
  var previousPoints: [PointsSegment] = []
  var brushSize: Double = 30
  var baseBrushSize = 30.0
  var scrollViewScale: CGFloat = 1.0
  var imageIsBeingProcessed = false
  var selectedIndex = 1
}
