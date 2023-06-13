//
//  EditControlView.swift
//  ImageEraser
//
//  Created by Christopher White on 10/10/2022.
//

import SwiftUI

struct EditControlView: View {

  // MARK: Internal

  @Bindable var state: EditState
  @State var shouldShowBrushPopover = false

  var body: some View {
    HStack(spacing: 8) {
      Button(action: {
        guard let data = state.imageData else { return }
        state.redoImageData.append(data)
        state.imageData = state.undoImageData.removeLast()
      }, label: {
        Image(systemName: "arrow.uturn.backward.circle")
          .font(.title)
      })
      .tint(.white)
      .disabled(undoDisabled)
      Button(action: {
        guard let data = state.imageData else { return }
        state.undoImageData.append(data)
        state.imageData = state.redoImageData.removeLast()
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
            BrushPropertiesContentView(brushSize: $state.brushSize)
              .padding()
          })
      }
    }
    .padding()
  }

  // MARK: Private

  private var undoDisabled: Bool {
    state.undoImageData.isEmpty
  }

  private var redoDisabled: Bool {
    state.redoImageData.isEmpty
  }
}
