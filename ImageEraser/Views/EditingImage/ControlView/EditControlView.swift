//
//  EditControlView.swift
//  ImageEraser
//
//  Created by Christopher White on 10/10/2022.
//

import SwiftUI

struct EditControlView: View {

  // MARK: Internal

  @Binding var redoablePhotoData: [Data]
  @State var oldPhotoData: [Data] = []
  @Binding var photoData: Data
  @Binding var brushSize: Double
  @State var shouldShowBrushPopover = false

  var body: some View {
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
            BrushPropertiesContentView(brushSize: $brushSize)
              .padding()
          })
      }
    }
    .padding()
  }

  // MARK: Private

  private var undoDisabled: Bool {
    oldPhotoData.isEmpty
  }

  private var redoDisabled: Bool {
    redoablePhotoData.isEmpty
  }
}
