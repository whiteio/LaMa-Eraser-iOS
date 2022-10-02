//
//  EditView.swift
//  ImageEraser
//
//  Created by Christopher White on 02/09/2022.
//

import Alamofire
import SwiftUI

struct EditView: View {
    var showDebugMask = false

    @EnvironmentObject var navigationStore: NavigationStore

    @State var undoDisabled = true
    @State var redoDisabled = true
    @State var imageState: ImageState = .init(imageSize: .zero, rectSize: .zero)
    @State var photoData: Data
    @State var oldPhotoData: [Data] = []
    @State var redoablePhotoData: [Data] = []
    @State var maskPoints: PointsSegment = .init(configuration: SegmentConfiguration(brushSize: 30),
                                                 rectPoints: [],
                                                 scaledPoints: [])
    @State var previousPointsSegments: [PointsSegment] = []
    @State var currentBrushSize: Double = 30
    @State var redoableSegments: [PointsSegment] = []
    @State var baseBrushSize = 30.0
    @State var scrollViewScale: CGFloat = 1.0
    @State var imageIsBeingProcessed = false

    init(photoData: Data) {
        _photoData = State(initialValue: photoData)
    }

    var body: some View {
        VStack {
            ZoomableScrollView(contentScale: $scrollViewScale) {
                ImageMaskingView(imageState: $imageState,
                                 selectedPhotoData: photoData,
                                 points: $maskPoints,
                                 previousPointsSegments: $previousPointsSegments,
                                 brushSize: $currentBrushSize,
                                 redoableSegments: $redoableSegments)
                    .overlay(loadingSpinnerView())
            }
            .onChange(of: scrollViewScale, perform: { newValue in
                currentBrushSize = baseBrushSize / newValue
            })
        }
        .navigationTitle("ERASER")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button(action: {
                    redoablePhotoData.append(photoData)
                    photoData = oldPhotoData.removeLast()
                }, label: {
                    Image(systemName: "arrow.uturn.backward.circle")
                })
                .tint(.white)
                .disabled(undoDisabled)
                Button(action: {
                    oldPhotoData.append(photoData)
                    photoData = redoablePhotoData.removeLast()
                }, label: {
                    Image(systemName: "arrow.uturn.forward.circle")
                })
                .tint(.white)
                .disabled(redoDisabled)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button(action: {
                    navigationStore.dismissView()
                }, label: {
                    Text("Cancel")
                })
                Spacer()
            }
        }
        .onChange(of: redoablePhotoData) { newValue in
            redoDisabled = newValue.isEmpty
        }
        .onChange(of: oldPhotoData, perform: { newValue in
            undoDisabled = newValue.isEmpty
        })
        .onChange(of: previousPointsSegments) { segments in
            if !segments.isEmpty {
                submitForInpainting()
            }
        }
    }

    @ViewBuilder func loadingSpinnerView() -> some View {
        if imageIsBeingProcessed {
            ProgressView("Loading")
                .tint(Color.purple)
        }
    }

    func submitForInpainting() {
        guard let maskImageData = getMaskImageDataFromPath() else { return }
        imageIsBeingProcessed = true
        let originalImageData = photoData

        if showDebugMask {
            debugAddPathToImageData()
        }

        let request = AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(originalImageData,
                                         withName: "image",
                                         fileName: "dog_photo.png",
                                         mimeType: "image/png")
                multipartFormData.append(maskImageData,
                                         withName: "mask",
                                         fileName: "masker_image.png",
                                         mimeType: "image/png")

            }, to: "http://127.0.0.1:9001/inpaint",
            method: .post
        )

        request.response { response in
            guard let data = response.data else { return }
            imageIsBeingProcessed = false
            redoablePhotoData.removeAll()
            oldPhotoData.append(photoData)
            photoData = data
        }

        previousPointsSegments.removeAll()
    }

    func debugAddPathToImageData() {
        let data = photoData
        let image = UIImage(data: data)
        let scaledSegments = previousPointsSegments.scaledSegmentsToPath(imageState: imageState)

        if let cgImage = image?.cgImage,
           let newCGImage = cgImage.createMaskFromPath(scaledSegments,
                                                       lineWidth: maskPoints.configuration.brushSize)
        {
            let newImage = UIImage(cgImage: newCGImage)
            if let newData = newImage.pngData() {
                photoData = newData
            }
        }
    }

    func getMaskImageDataFromPath() -> Data? {
        let data = photoData
        let image = UIImage(data: data)
        let scaledSegments = previousPointsSegments.scaledSegmentsToPath(imageState: imageState)

        if let cgImage = image?.cgImage,
           let newCGImage = cgImage.createMaskFromPath(scaledSegments,
                                                       lineWidth: maskPoints.configuration.brushSize)
        {
            let newImage = UIImage(cgImage: newCGImage)
            if let newData = newImage.pngData() {
                return newData
            }
        }

        return nil
    }

    func addLassoPathToImageData() {
        let data = photoData
        let image = UIImage(data: data)
        let scaledSegments = previousPointsSegments.scaledSegmentsToPath(imageState: imageState)

        if let cgImage = image?.cgImage,
           let newCGImage = cgImage.createMaskFromLassoPath(scaledSegments,
                                                            lineWidth: currentBrushSize)
        {
            let newImage = UIImage(cgImage: newCGImage)
            if let newData = newImage.pngData() {
                photoData = newData
            }
        }
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditView(photoData: Data())
                .preferredColorScheme(.dark)
        }
    }
}
