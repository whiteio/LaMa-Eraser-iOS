//
//  EditView.swift
//  ImageEraser
//
//  Created by Christopher White on 02/09/2022.
//

import SwiftUI

struct EditView: View {
    @EnvironmentObject var navigationStore: NavigationStore

    @State var undoDisabled = true
    @State var redoDisabled = true
    @State var submitButtonDisabled = true

    @State var imageState: ImageState = ImageState(imageSize: .zero, rectSize: .zero)
    @State var photoData: Data
    @State var maskPoints: PointsSegment = PointsSegment(rectPoints: [],
                                                         scaledPoints: [])
    @State var previousPointsSegments: [PointsSegment] = []
    @State var brushSize: Double = 30
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
                                 brushSize: $brushSize,
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
                                            lineWidth: brushSize) {
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
