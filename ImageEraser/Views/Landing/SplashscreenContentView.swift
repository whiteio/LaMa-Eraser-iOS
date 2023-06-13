//
//  SplashscreenContentView.swift
//  ImageEraser
//
//  Created by Christopher White on 04/09/2022.
//

import PhotosUI
import SwiftUI

struct SplashscreenContentView: View {
  @EnvironmentObject var store: NavigationStore

  @State var selectedItem: PhotosPickerItem?

  var body: some View {
    VStack {
      Text("erase objects from images.")
        .frame(width: 260, alignment: .leading)
        .font(.largeTitle)
        .bold()
      PhotosPicker(
        selection: $selectedItem,
        matching: .images,
        photoLibrary: .shared())
      {
        SelectContentView()
      }
      .tint(.black)
      .onChange(of: selectedItem) { newItem in
        Task {
          if let data = try? await newItem?.loadTransferable(type: Data.self) {
            store.navigateToPath(.editPhoto(data))
          }
        }
      }
    }
  }
}
