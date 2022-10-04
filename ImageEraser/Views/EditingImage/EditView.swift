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
    @State var shouldShowBrushPopover = false
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
                .overlay(loadingSpinnerView())
                .onChange(of: scrollViewScale, perform: { newValue in
                    currentBrushSize = baseBrushSize / newValue
                })

                HStack(spacing: 8) {
                    Button(action: {
                        redoablePhotoData.append(photoData)
                        photoData = oldPhotoData.removeLast()
                    }, label: {
                        Image(systemName: "arrow.uturn.backward.circle")
                            .font(.title)
                    })
                    .tint(.white)
                    .disabled(undoDisabled)
                    Button(action: {
                        oldPhotoData.append(photoData)
                        photoData = redoablePhotoData.removeLast()
                    }, label: {
                        Image(systemName: "arrow.uturn.forward.circle")
                            .font(.title)
                    })
                    .tint(.white)
                    .disabled(redoDisabled)

                    Button {
                        shouldShowBrushPopover = true
                    } label: {
                        Image(systemName: "pencil.tip.crop.circle")
                            .font(.title)
                            .tint(.white)
                            .alwaysPopover(isPresented: $shouldShowBrushPopover, content: {
                                BrushPropertiesContentView(brushSize: $currentBrushSize)
                                    .padding()
                            })
                    }
                }
                .padding()
            }
            SegmentedControlView(selectedIndex: $selectedIndex,
                                 items: [("Move", "move.3d"),
                                         ("Brush", "paintbrush"),
                                         ("Lasso", "lasso")])
                .onChange(of: selectedIndex, perform: { value in
                    print("Index changed to \(value)")
                })
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
                .tint(Color.white)
                .padding()
                .background(Color.black)
                .cornerRadius(12)
        }
    }

    func submitForInpainting() {
        var maskImageData: Data? = Data()
        if mode == .standardMask {
            maskImageData = getMaskImageDataFromPath()
        } else if mode == .lasso {
            maskImageData = getLassoMaskDataFromPath()
        }

        guard let data = maskImageData else { return }

        withAnimation(.easeInOut(duration: 0.1)) {
            imageIsBeingProcessed = true
        }

        let originalImageData = photoData

        if showDebugMask {
            if mode == .standardMask {
                debugAddPathToImageData()
            } else {
                debugAddLassoPathToImageData()
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

            withAnimation(.easeInOut(duration: 0.1)) {
                imageIsBeingProcessed = false
            }

            redoablePhotoData.removeAll()
            oldPhotoData.append(photoData)
            photoData = data
            previousPointsSegments.removeAll()
        }
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

    func debugAddLassoPathToImageData() {
        let data = photoData
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

    func getLassoMaskDataFromPath() -> Data? {
        let data = photoData
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

struct VerticalLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.icon
            configuration.title
        }
    }
}
