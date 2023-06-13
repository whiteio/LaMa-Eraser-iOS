//
//  BrushPropertiesContentView.swift
//  ImageEraser
//
//  Created by Christopher White on 02/10/2022.
//

import SwiftUI

// MARK: - BrushPropertiesContentView

struct BrushPropertiesContentView: View {
  @Binding var brushSize: Double

  var body: some View {
    VStack {
      Slider(value: $brushSize, in: 10 ... 50, step: 1)
        .frame(maxWidth: .infinity)
      HStack {
        Text("Brush size:")
        Circle()
          .fill(Color.accentColor)
          .frame(width: brushSize, height: brushSize)
      }
    }
  }
}

// MARK: - BrushPropertiesContentView_Previews

struct BrushPropertiesContentView_Previews: PreviewProvider {
  @State static var brushSize = 30.0

  static var previews: some View {
    BrushPropertiesContentView(brushSize: $brushSize)
  }
}
