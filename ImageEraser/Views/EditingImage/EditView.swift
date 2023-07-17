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
    _state = State(wrappedValue: EditState(photoData: photoData))
  }

  // MARK: Internal

  var showDebugMask = false

  @Environment(NavigationStore.self) var navigationStore
  @Environment(EditViewModel.self) var interactor
  @State var state: EditState

  var currentlyEditablePhoto: ShareableImage {
    guard let data = state.imageData, let image = UIImage(data: data) else {
      return ShareableImage(image: Image(""), caption: "")
    }
    return ShareableImage(image: Image(uiImage: image), caption: "Eraser image!")
  }

  var body: some View {
    ZStack(alignment: .bottom) {
      ZStack(alignment: .topLeading) {
        ZoomableScrollView(contentScale: $state.scrollViewScale) {
          ImageMaskingView(
            state: state)
        }
        .overlay(opacityLoadingOverlay())
        .overlay(loadingSpinnerView())
        .onChange(of: state.scrollViewScale, initial: false) { _, newValue in
          state.brushSize = state.baseBrushSize / newValue
        }

        EditControlView(state: state)
          .overlay(opacityLoadingOverlay())
          .environment(state)
      }

      editModePicker()
        .pickerStyle(.segmented)
        .padding()
        .overlay(opacityLoadingOverlay())
        .onChange(of: state.selectedIndex, initial: false) { _, newSelectedIndex in
          let newState = getNewState(for: newSelectedIndex)
          state.mode = newState
        }
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
    .onChange(of: state.previousPoints, initial: false) { _, newSegments in
      if !newSegments.isEmpty {
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
