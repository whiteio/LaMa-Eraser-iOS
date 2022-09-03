//
//  EditView.swift
//  ImageEraser
//
//  Created by Christopher White on 02/09/2022.
//

import SwiftUI

struct Coordinates {
    var xCoordinate: CGFloat
    var yCoordinate: CGFloat
}

struct EditView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var undoDisabled = true
    @State var redoDisabled = true
    @State var submitButtonDisabled = true


    @State var photoData: Data
    @State var maskPoints: [CGPoint] = []
    @State var previousPointsSegments: [[CGPoint]] = []
    @State var brushSize: Double = 30
    @State var redoableSegments: [[CGPoint]] = []
    @State var scale: CGFloat = 1.0
    @State var offset: Coordinates = Coordinates(xCoordinate: 0, yCoordinate: 0)

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

    func addPathToImageData() {

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
