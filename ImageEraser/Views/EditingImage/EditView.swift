//
//  EditView.swift
//  ImageEraser
//
//  Created by Christopher White on 02/09/2022.
//

import Alamofire
import SwiftUI

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
    @EnvironmentObject var interactor: EditInteractor
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
                interactor.submitForInpainting(state: state)
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
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditView(photoData: Data())
                .preferredColorScheme(.dark)
        }
    }
}
