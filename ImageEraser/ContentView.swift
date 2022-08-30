//
//  ContentView.swift
//  ImageEraser
//
//  Created by Christopher White on 30/08/2022.
//

import SwiftUI
import RiveRuntime
import PhotosUI

struct ContentView: View {
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedPhotoData: Data? {
        didSet {
            shouldShowSelectedPhoto = selectedPhotoData != nil
        }
    }
    @State private var shouldShowSelectedPhoto = false

    var body: some View {
        VStack {
            if let selectedPhotoData, let image = UIImage(data: selectedPhotoData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipped()
            } else {
                Text("erase objects from images.")
                    .frame(width: 260, alignment: .leading)
                    .font(.largeTitle)
                    .bold()
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    SelectContentView()
                }
            }
        }
        .tint(.black)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RiveViewModel(fileName: "shapes").view()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .blur(radius: 30)
                .blendMode(.hardLight)
        )
        .background(
            Image("Spline")
                .blur(radius: 50)
                .offset(x: 200, y: 100)
        )
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    selectedPhotoData = data
                }
            }
        }
    }
}

struct SelectContentView: View {
    let button = RiveViewModel(fileName: "button", autoPlay: false)

    var body: some View {
        VStack(alignment: .leading) {
            button.view()
                .frame(width: 236, height: 64)
                .background(
                    Color.black
                        .cornerRadius(30)
                        .blur(radius: 10)
                        .opacity(0.3)
                        .offset(y: 10)
                )
                .overlay(
                    Label("Select a photo", systemImage: "photo.fill")
                        .bold()
                        .offset(x: 4, y: 4)
                )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
