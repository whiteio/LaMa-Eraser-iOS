//
//  EditView.swift
//  ImageEraser
//
//  Created by Christopher White on 02/09/2022.
//

import Alamofire
import SwiftUI

// MARK: - EditView

struct EditView: View {

  // MARK: Lifecycle

  init(photoData: Data) {
    _state = StateObject(wrappedValue: EditState(photoData: photoData))
  }

  // MARK: Internal

  var showDebugMask = false

  @EnvironmentObject var navigationStore: NavigationStore
  @EnvironmentObject var interactor: EditInteractor
  @StateObject var state: EditState

  var currentlyEditablePhoto: ShareableImage {
    guard let image = UIImage(data: state.imageData) else {
      return ShareableImage(image: Image(""), caption: "")
    }
    return ShareableImage(image: Image(uiImage: image), caption: "Eraser image!")
  }

  var body: some View {
    ZStack(alignment: .bottom) {
      ZStack(alignment: .topLeading) {
        ZoomableScrollView(contentScale: $state.scrollViewScale) {
          ImageMaskingView(
            editState: state,
            imageState: $state.imagePresentationState,
            selectedPhotoData: state.imageData,
            brushSize: $state.brushSize,
            imageIsProcessing: $state.imageIsBeingProcessed,
            mode: $state.mode)
        }
        .overlay(opacityLoadingOverlay())
        .overlay(loadingSpinnerView())
        .onChange(of: state.scrollViewScale, perform: { newValue in
          state.brushSize = state.baseBrushSize / newValue
        })

        EditControlView(
          redoablePhotoData: $state.redoImageData,
          photoData: $state.imageData,
          brushSize: $state.brushSize)
          .overlay(opacityLoadingOverlay())
      }

      editModePicker()
        .pickerStyle(.segmented)
        .padding()
        .overlay(opacityLoadingOverlay())
        .onChange(of: state.selectedIndex, perform: { newSelectedIndex in
          let newState = getNewState(for: newSelectedIndex)
          state.mode = newState
        })
    }
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
        ShareLink(
          item: currentlyEditablePhoto,
          preview: SharePreview(
            "Photo selected",
            image: currentlyEditablePhoto.image))
      }
    }
    .onChange(of: state.previousPoints) { segments in
      if !segments.isEmpty {
        interactor.submitForInpainting(state: state)
      }
    }
  }

  @ViewBuilder
  func loadingSpinnerView() -> some View {
    if state.imageIsBeingProcessed {
      ProgressView("Loading")
        .tint(Color.white)
        .padding()
        .background(Color.black)
        .cornerRadius(12)
    }
  }

  @ViewBuilder
  func opacityLoadingOverlay() -> some View {
    if state.imageIsBeingProcessed {
      Color.black.opacity(0.5)
    }
  }

  func getNewState(for index: Int) -> EditMode {
    let newState: EditMode

    switch index {
    case 0:
      newState = .move
    case 1:
      newState = .standardMask
    case 2:
      newState = .lasso
    default:
      newState = .standardMask
    }

    return newState
  }

  // MARK: Fileprivate

  fileprivate func editModePicker() -> Picker<Text, Int, TupleView<(some View, some View)>> {
    Picker("Choose an option", selection: $state.selectedIndex, content: {
      Text("Move").tag(0)
      Text("Brush").tag(1)
    })
  }
}

// MARK: - EditView_Previews

struct EditView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      EditView(photoData: Data())
        .preferredColorScheme(.dark)
    }
  }
}
