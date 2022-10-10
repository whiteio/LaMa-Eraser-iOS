//
//  EditView.swift
//  ImageEraser
//
//  Created by Christopher White on 02/09/2022.
//

import Alamofire
import SwiftUI

enum Mode {
    case standardMask, lasso, move
}

struct EditableImage: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.image)
    }

    public var image: Image
    public var caption: String
}

struct EditView: View {
    var showDebugMask = false

    @EnvironmentObject var navigationStore: NavigationStore
    @State var mode: Mode = .standardMask

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
    @State var selectedIndex = 1

    var currentlyEditablePhoto: EditableImage {
        guard let image = UIImage(data: photoData) else { return EditableImage(image: Image(""), caption: "") }
        return EditableImage(image: Image(uiImage: image), caption: "Eraser image!")
    }

    init(photoData: Data) {
        _photoData = State(initialValue: photoData)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack(alignment: .topLeading) {
                ZoomableScrollView(contentScale: $scrollViewScale) {
                    ImageMaskingView(imageState: $imageState,
                                     selectedPhotoData: photoData,
                                     points: $maskPoints,
                                     previousPointsSegments: $previousPointsSegments,
                                     brushSize: $currentBrushSize,
                                     redoableSegments: $redoableSegments,
                                     imageIsProcessing: $imageIsBeingProcessed,
                                     mode: $mode)
                }
                .overlay(opacityLoadingOverlay())
                .overlay(loadingSpinnerView())
                .onChange(of: scrollViewScale, perform: { newValue in
                    currentBrushSize = baseBrushSize / newValue
                })

                EditControlView(redoablePhotoData: $redoablePhotoData,
                                photoData: $photoData,
                                brushSize: $currentBrushSize)
                    .overlay(opacityLoadingOverlay())
            }

            Picker("Choose an option", selection: $selectedIndex, content: {
                Text("Move").tag(0)
                Text("Brush").tag(1)
            })
            .pickerStyle(.segmented)
            .padding()
            .overlay(opacityLoadingOverlay())
        }
        .onChange(of: selectedIndex, perform: { newSelectedIndex in
            switch newSelectedIndex {
            case 0:
                mode = .move
            case 1:
                mode = .standardMask
            case 2:
                mode = .lasso
            default:
                mode = .standardMask
            }
        })
        .navigationTitle("ERASER")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button(action: {
                    navigationStore.dismissView()
                }, label: {
                    Text("Cancel")
                })
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                ShareLink(item: currentlyEditablePhoto,
                          preview: SharePreview("Photo selected",
                                                image: currentlyEditablePhoto.image))
            }
        }
        .onChange(of: previousPointsSegments) { segments in
            if !segments.isEmpty {
                submitForInpainting()
            }
        }
    }

    @ViewBuilder func loadingSpinnerView() -> some View {
        if imageIsBeingProcessed {
            ProgressView("Loading")
                .tint(Color.white)
                .padding()
                .background(Color.black)
                .cornerRadius(12)
        }
    }

    @ViewBuilder func opacityLoadingOverlay() -> some View {
        if imageIsBeingProcessed {
            Color.black.opacity(0.5)
        }
    }

    func submitForInpainting() {
        let maskData = mode == .standardMask ? getMaskImageDataFromPath() : getLassoMaskDataFromPath(data: photoData)
        guard let data = maskData else { return }

        withAnimation(.easeInOut(duration: 0.2)) {
            imageIsBeingProcessed = true
        }

        let originalImageData = photoData

        if showDebugMask {
            if mode == .standardMask {
                debugAddPathToImageData(photoData)
            } else {
                debugAddLassoPathToImageData(photoData)
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
                imageIsBeingProcessed = false
            }

            redoablePhotoData.removeAll()
            oldPhotoData.append(photoData)
            photoData = data
            previousPointsSegments.removeAll()
        }
    }

    func debugAddPathToImageData(_ data: Data) {
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

    func debugAddLassoPathToImageData(_ data: Data) {
        let image = UIImage(data: data)
        let scaledSegments = previousPointsSegments.scaledSegmentsToPath(imageState: imageState)

        if let cgImage = image?.cgImage,
           let newCGImage = cgImage.createMaskFromLassoPath(scaledSegments,
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

    func getLassoMaskDataFromPath(data: Data) -> Data? {
        let image = UIImage(data: data)
        let scaledSegments = previousPointsSegments.scaledSegmentsToPath(imageState: imageState)

        if let cgImage = image?.cgImage,
           let newCGImage = cgImage.createMaskFromLassoPath(scaledSegments,
                                                            lineWidth: currentBrushSize)
        {
            let newImage = UIImage(cgImage: newCGImage)
            if let newData = newImage.pngData() {
                return newData
            }
        }

        return nil
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
