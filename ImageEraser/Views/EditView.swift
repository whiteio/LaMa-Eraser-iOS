//
//  EditView.swift
//  ImageEraser
//
//  Created by Christopher White on 02/09/2022.
//

import SwiftUI

struct EditView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var undoDisabled = true
    @State var redoDisabled = true
    @State var submitButtonDisabled = true

    @State var photoData: Data
    @State var maskPoints: PointsSegment = PointsSegment(rectPoints: [], scaledPoints: [], imageSize: .zero, rectSize: .zero)
    @State var previousPointsSegments: [PointsSegment] = []
    @State var brushSize: Double = 30
    @State var redoableSegments: [PointsSegment] = []

    init(photoData: Data) {
        self._photoData = State(initialValue: photoData)
    }

    var body: some View {
        VStack {
            ZoomableScrollView {
                ImageMaskingView(selectedPhotoData: photoData,
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
                    self.presentationMode.wrappedValue.dismiss()
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

    var scaledSegmentsToPath: CGPath {
        var path = Path()

        for segment in previousPointsSegments {
            guard let firstPoint = segment.scaledPoints.first else { return path.cgPath }

            path.move(to: firstPoint)

            path.move(to: firstPoint)
            for pointIndex in 1..<segment.scaledPoints.count {
                path.addLine(to: segment.scaledPoints[pointIndex])
            }
        }

        let mirror = CGAffineTransform(scaleX: 1,
                                       y: -1)
        let translate = CGAffineTransform(translationX: 0,
                                          y: previousPointsSegments.first!.imageSize.height)
        var concatenated = mirror.concatenating(translate)


        if let cgPath = path.cgPath.copy(using: &concatenated) {
            return cgPath
        } else {
            return path.cgPath
        }
    }

    func addPathToImageData() {
        let data = photoData
        let image = UIImage(data: data)
        let cgImage = image?.cgImage

        if let cgImage = cgImage {
            let newCGImage = cgImage.addPath(scaledSegmentsToPath)
            if let newCGImage = newCGImage {
                let newImage = UIImage(cgImage: newCGImage)
                if let newData = newImage.pngData() {
                    photoData = newData
                }
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
