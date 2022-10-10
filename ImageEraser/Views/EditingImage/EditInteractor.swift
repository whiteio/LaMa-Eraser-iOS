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
        let maskData = state.mode == .standardMask ? getMaskImageDataFromPath(state: state) : getLassoMaskDataFromPath(state: state)
        guard let data = maskData else { return }

        withAnimation(.easeInOut(duration: 0.2)) {
            state.imageIsBeingProcessed = true
        }

        let originalImageData = state.photoData

        if false {
            if state.mode == .standardMask {
                debugAddPathToImageData(state: state)
            } else {
                debugAddLassoPathToImageData(state: state)
            }
        }

        let request = AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(originalImageData,
                                         withName: "image",
                                         fileName: "dog_photo.png",
                                         mimeType: "image/png")
                multipartFormData.append(data,
                                         withName: "mask",
                                         fileName: "masker_image.png",
                                         mimeType: "image/png")

            }, to: "http://127.0.0.1:9001/inpaint",
            method: .post
        )

        request.response { response in
            guard let data = response.data else { return }

            withAnimation(.easeInOut(duration: 0.2)) {
                state.imageIsBeingProcessed = false
            }

            state.redoablePhotoData.removeAll()
            state.oldPhotoData.append(state.photoData)
            state.photoData = data
            state.previousPointsSegments.removeAll()
        }
    }

    func debugAddPathToImageData(state: EditState) {
        let image = UIImage(data: state.photoData)
        let scaledSegments = state.previousPointsSegments.scaledSegmentsToPath(imageState: state.imageState)

        if let cgImage = image?.cgImage,
           let newCGImage = cgImage.createMaskFromPath(scaledSegments,
                                                       lineWidth: state.maskPoints.configuration.brushSize)
        {
            let newImage = UIImage(cgImage: newCGImage)
            if let newData = newImage.pngData() {
                state.photoData = newData
            }
        }
    }

    func debugAddLassoPathToImageData(state: EditState) {
        let image = UIImage(data: state.photoData)
        let scaledSegments = state.previousPointsSegments.scaledSegmentsToPath(imageState: state.imageState)

        if let cgImage = image?.cgImage,
           let newCGImage = cgImage.createMaskFromLassoPath(scaledSegments,
                                                            lineWidth: state.maskPoints.configuration.brushSize)
        {
            let newImage = UIImage(cgImage: newCGImage)
            if let newData = newImage.pngData() {
                state.photoData = newData
            }
        }
    }

    func getMaskImageDataFromPath(state: EditState) -> Data? {
        let data = state.photoData
        let image = UIImage(data: data)
        let scaledSegments = state.previousPointsSegments.scaledSegmentsToPath(imageState: state.imageState)

        if let cgImage = image?.cgImage,
           let newCGImage = cgImage.createMaskFromPath(scaledSegments,
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
        let image = UIImage(data: state.photoData)
        let scaledSegments = state.previousPointsSegments.scaledSegmentsToPath(imageState: state.imageState)

        if let cgImage = image?.cgImage,
           let newCGImage = cgImage.createMaskFromLassoPath(scaledSegments,
                                                            lineWidth: state.currentBrushSize)
        {
            let newImage = UIImage(cgImage: newCGImage)
            if let newData = newImage.pngData() {
                return newData
            }
        }

        return nil
    }
}
