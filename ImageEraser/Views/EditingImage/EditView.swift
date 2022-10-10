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
    @StateObject var state: EditState

    var currentlyEditablePhoto: EditableImage {
        guard let image = UIImage(data: state.photoData) else { return EditableImage(image: Image(""), caption: "") }
        return EditableImage(image: Image(uiImage: image), caption: "Eraser image!")
    }

    init(photoData: Data) {
        _state = StateObject(wrappedValue: EditState(photoData: photoData))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack(alignment: .topLeading) {
                ZoomableScrollView(contentScale: $state.scrollViewScale) {
                    ImageMaskingView(imageState: $state.imageState,
                                     selectedPhotoData: state.photoData,
                                     points: $state.maskPoints,
                                     previousPointsSegments: $state.previousPointsSegments,
                                     brushSize: $state.currentBrushSize,
                                     redoableSegments: $state.redoableSegments,
                                     imageIsProcessing: $state.imageIsBeingProcessed,
                                     mode: $state.mode)
                }
                .overlay(opacityLoadingOverlay())
                .overlay(loadingSpinnerView())
                .onChange(of: state.scrollViewScale, perform: { newValue in
                    state.currentBrushSize = state.baseBrushSize / newValue
                })

                EditControlView(redoablePhotoData: $state.redoablePhotoData,
                                photoData: $state.photoData,
                                brushSize: $state.currentBrushSize)
                    .overlay(opacityLoadingOverlay())
            }

            Picker("Choose an option", selection: $state.selectedIndex, content: {
                Text("Move").tag(0)
                Text("Brush").tag(1)
            })
            .pickerStyle(.segmented)
            .padding()
            .overlay(opacityLoadingOverlay())
        }
        .onChange(of: state.selectedIndex, perform: { newSelectedIndex in
            switch newSelectedIndex {
            case 0:
                state.mode = .move
            case 1:
                state.mode = .standardMask
            case 2:
                state.mode = .lasso
            default:
                state.mode = .standardMask
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
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                ShareLink(item: currentlyEditablePhoto,
                          preview: SharePreview("Photo selected",
                                                image: currentlyEditablePhoto.image))
            }
        }
        .onChange(of: state.previousPointsSegments) { segments in
            if !segments.isEmpty {
                submitForInpainting()
            }
        }
    }

    @ViewBuilder func loadingSpinnerView() -> some View {
        if state.imageIsBeingProcessed {
            ProgressView("Loading")
                .tint(Color.white)
                .padding()
                .background(Color.black)
                .cornerRadius(12)
        }
    }

    @ViewBuilder func opacityLoadingOverlay() -> some View {
        if state.imageIsBeingProcessed {
            Color.black.opacity(0.5)
        }
    }

    func submitForInpainting() {
        let maskData = state.mode == .standardMask ? getMaskImageDataFromPath() : getLassoMaskDataFromPath(data: state.photoData)
        guard let data = maskData else { return }

        withAnimation(.easeInOut(duration: 0.2)) {
            state.imageIsBeingProcessed = true
        }

        let originalImageData = state.photoData

        if showDebugMask {
            if state.mode == .standardMask {
                debugAddPathToImageData(state.photoData)
            } else {
                debugAddLassoPathToImageData(state.photoData)
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

    func debugAddPathToImageData(_ data: Data) {
        let image = UIImage(data: data)
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

    func debugAddLassoPathToImageData(_ data: Data) {
        let image = UIImage(data: data)
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

    func getMaskImageDataFromPath() -> Data? {
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

    func getLassoMaskDataFromPath(data: Data) -> Data? {
        let image = UIImage(data: data)
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

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditView(photoData: Data())
                .preferredColorScheme(.dark)
        }
    }
}
