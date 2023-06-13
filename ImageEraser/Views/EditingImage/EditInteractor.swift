//
//  EditInteractor.swift
//  ImageEraser
//
//  Created by Christopher White on 10/10/2022.
//

import Alamofire
import SwiftUI

class EditInteractor: ObservableObject {
  func submitForInpainting(state: EditState) {
    let maskData = state.mode == .standardMask
      ? getMaskImageDataFromPath(state: state)
      : getLassoMaskDataFromPath(state: state)
    guard let data = maskData else { return }

    withAnimation(.easeInOut(duration: 0.2)) {
      state.imageIsBeingProcessed = true
    }

    let originalImageData = state.imageData

    if false {
      if state.mode == .standardMask {
        debugAddPathToImageData(state: state)
      } else {
        debugAddLassoPathToImageData(state: state)
      }
    }

      guard let portNumber = Bundle.main.infoDictionary?["PortNumber"] as? Int else { return }

    let request = AF.upload(
      multipartFormData: { multipartFormData in
        multipartFormData.append(
          originalImageData,
          withName: "image",
          fileName: "input.png",
          mimeType: "image/png")
        multipartFormData.append(
          data,
          withName: "mask",
          fileName: "mask.png",
          mimeType: "image/png")

      }, to: "http://127.0.0.1:\(portNumber)/inpaint",
      method: .post)

    request.response { response in
      guard let data = response.data else { return }

      withAnimation(.easeInOut(duration: 0.2)) {
        state.imageIsBeingProcessed = false
      }

      state.redoImageData.removeAll()
      state.undoImageData.append(state.imageData)
      state.imageData = data
      state.previousPoints.removeAll()
    }
  }

  func debugAddPathToImageData(state: EditState) {
    let image = UIImage(data: state.imageData)
    let scaledSegments = state.previousPoints.scaledSegmentsToPath(imageState: state.imagePresentationState)

    if
      let cgImage = image?.cgImage,
      let newCGImage = cgImage.createMaskFromPath(
        scaledSegments,
        lineWidth: state.maskPoints.configuration.brushSize)
    {
      let newImage = UIImage(cgImage: newCGImage)
      if let newData = newImage.pngData() {
        state.imageData = newData
      }
    }
  }

  func debugAddLassoPathToImageData(state: EditState) {
    let image = UIImage(data: state.imageData)
    let scaledSegments = state.previousPoints.scaledSegmentsToPath(imageState: state.imagePresentationState)

    if
      let cgImage = image?.cgImage,
      let newCGImage = cgImage.createMaskFromLassoPath(
        scaledSegments,
        lineWidth: state.maskPoints.configuration.brushSize)
    {
      let newImage = UIImage(cgImage: newCGImage)
      if let newData = newImage.pngData() {
        state.imageData = newData
      }
    }
  }

  func getMaskImageDataFromPath(state: EditState) -> Data? {
    let data = state.imageData
    let image = UIImage(data: data)
    let scaledSegments = state.previousPoints.scaledSegmentsToPath(imageState: state.imagePresentationState)

    if
      let cgImage = image?.cgImage,
      let newCGImage = cgImage.createMaskFromPath(
        scaledSegments,
        lineWidth: state.maskPoints.configuration.brushSize)
    {
      let newImage = UIImage(cgImage: newCGImage)
      if let newData = newImage.pngData() {
        return newData
      }
    }

    return nil
  }

  func getLassoMaskDataFromPath(state: EditState) -> Data? {
    let image = UIImage(data: state.imageData)
    let scaledSegments = state.previousPoints.scaledSegmentsToPath(imageState: state.imagePresentationState)

    if
      let cgImage = image?.cgImage,
      let newCGImage = cgImage.createMaskFromLassoPath(
        scaledSegments,
        lineWidth: state.brushSize)
    {
      let newImage = UIImage(cgImage: newCGImage)
      if let newData = newImage.pngData() {
        return newData
      }
    }

    return nil
  }
}
