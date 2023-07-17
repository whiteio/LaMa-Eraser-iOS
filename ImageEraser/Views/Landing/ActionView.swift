//
//  SplashscreenContentView.swift
//  ImageEraser
//
//  Created by Christopher White on 04/09/2022.
//

import PhotosUI
import SwiftUI

struct ActionView: View {
    @Environment(NavigationStore.self) var store

    @State var selectedItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 30) {
            Text("erase objects from images.")
                .frame(width: 260, alignment: .center)
                .font(.largeTitle)
                .bold()
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared())
            {
                SelectContentView()
            }
            .buttonStyle(.bordered)
            .font(.title3)
            .tint(.white)
            .onChange(of: selectedItem, initial: false) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        store.navigateToPath(.editPhoto(data))
                    }
                }
            }
        }
    }
}
