//
//  EditView.swift
//  ImageEraser
//
//  Created by Christopher White on 02/09/2022.
//

import SwiftUI
import Alamofire

struct EditView: View {
    @EnvironmentObject var navigationStore: NavigationStore

    @State var undoDisabled = true
    @State var redoDisabled = true
    @State var submitButtonDisabled = true

    @State var imageState: ImageState = ImageState(imageSize: .zero, rectSize: .zero)
    @State var photoData: Data
    @State var maskPoints: PointsSegment = PointsSegment(configuration: SegmentConfiguration(brushSize: 30),
                                                         rectPoints: [],
                                                         scaledPoints: [])
    @State var previousPointsSegments: [PointsSegment] = []
    @State var currentBrushSize: Double = 30
    @State var redoableSegments: [PointsSegment] = []

    init(photoData: Data) {
        self._photoData = State(initialValue: photoData)
    }

    var body: some View {
        VStack {
            ZoomableScrollView {
                ImageMaskingView(imageState: $imageState,
                                 selectedPhotoData: photoData,
                                 points: $maskPoints,
                                 previousPointsSegments: $previousPointsSegments,
                                 brushSize: $currentBrushSize,
                                 redoableSegments: $redoableSegments)
            }
        }
        .navigationTitle("ERASER")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button(action: {
                    redoableSegments.append(previousPointsSegments.removeLast())
                }, label: {
                    Image(systemName: "arrow.uturn.backward.circle")
                })
                .tint(.white)
                .disabled(undoDisabled)
                Button(action: {
                    previousPointsSegments.append(redoableSegments.removeLast())
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
                Button(action: addPathToImageData, label: {
                    Text("Erase!")
                })
                .disabled(submitButtonDisabled)
                Button(action: {
                    guard let dogPhotoURL =
                            Bundle.main.url(forResource: "dog_photo",
                                            withExtension: "png"),
                          let maskerImageURL =
                            Bundle.main.url(forResource: "masker_image",
                                            withExtension: "png") else {
                        return
                    }

                    guard let dogPhotoData = try? Data(contentsOf: dogPhotoURL) else { return }
                    guard let maskerImageData = try? Data(contentsOf: maskerImageURL) else { return }

                    guard let image = UIImage(data: dogPhotoData) else { return }
                    guard let masker = UIImage(data: maskerImageData) else { return }

                    let imageData = image.pngData()!
                    let maskerData = masker.pngData()!

                    let request = AF.upload(
                        multipartFormData: { multipartFormData in
                            multipartFormData.append(imageData,
                                                     withName: "image",
                                                     fileName: "dog_photo.png",
                                                     mimeType: "image/png")
                            multipartFormData.append(maskerData,
                                                     withName: "mask",
                                                     fileName: "masker_image.png",
                                                     mimeType: "image/png")

                        }, to: "http://127.0.0.1:9001/inpaint",
                        method: .post
                    )

                    print(request.description)
                    request.response { response in
                        print("Response is \(response)")
                    }
                    addPathToImageData()
                }, label: {
                    Text("Test request")
                })
            }
        }
        .onChange(of: redoableSegments) { undoneSegments in
            redoDisabled = undoneSegments.isEmpty
        }
        .onChange(of: previousPointsSegments) { segments in
            undoDisabled = segments.isEmpty
            submitButtonDisabled = segments.isEmpty
        }
    }

    func addPathToImageData() {
        let data = photoData
        let image = UIImage(data: data)

        if let cgImage = image?.cgImage,
           let newCGImage = cgImage.addPath(previousPointsSegments.scaledSegmentsToPath(imageState: imageState),
                                            lineWidth: maskPoints.configuration.brushSize) {
            let newImage = UIImage(cgImage: newCGImage)
            if let newData = newImage.pngData() {
                photoData = newData
            }
        }
    }

    func addLassoPathToImageData() {
        let data = photoData
        let image = UIImage(data: data)

        if let cgImage = image?.cgImage,
           let newCGImage = cgImage.addLassoPath(previousPointsSegments.scaledSegmentsToPath(imageState: imageState),
                                            lineWidth: currentBrushSize) {
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
